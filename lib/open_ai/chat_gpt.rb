# frozen_string_literal: true

module ChatGPT
  module ClassMethods
    def threads
      @threads ||= {}
    end

    def new_thread(chat_id)
      new_thread = ChatThread.new(initial_messages)
      threads[chat_id] = new_thread
    end

    def default_instruction
      <<~MSG
        You are in a group chat. In the first line of the message, you will receive the name of the user who sent that message.
        Different languages can be used.
        You don't have to sign your messages this way or use users' names without need.
      MSG
    end

    def first_user_message
      <<~MSG
        <@tyradee>:
        I drank some tea today.
      MSG
    end

    def first_bot_message
      <<~MSG
        Good for you!
      MSG
    end

    def initial_messages
      [
        { role: :system, content: default_instruction },
        { role: :user, content: first_user_message },
        { role: :assistant, content: first_bot_message }
      ]
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def init_session
    self.class.new_thread(@chat.id)
    send_message(session_restart_message)
  end

  def handle_gpt_command
    return unless bot_mentioned? || bot_replied_to? || private_chat?
    return if self.class.registered_commands.keys.any? { @text.match? Regexp.new(_1) }

    if !allowed_chat?
      reply(chat_not_allowed_message, parse_mode: "Markdown") if chat_not_allowed_message
      return
    end

    # Find the ChatThread current message belongs to (or create a fresh new one)
    @thread = self.class.threads[@chat.id] || self.class.new_thread(@chat.id)

    # `text` is whatever the current user wrote, except the bot username (unless it's only whitespace)
    text = @text_without_bot_mentions
    text = nil if text.gsub(/\s/, "").empty?

    # `target_text` is the text of the message current user replies to
    target_text = @replies_to&.text || @replies_to&.caption
    target_text = nil if @target&.username == config.bot_username


    name = "@#{@user.username}"
    target_name = "@#{@replies_to&.from&.username}"

    # If present, glue together current user text and reply target text, marking them with usernames
    text = [
      add_name(target_name, target_text),
      add_name(name, text)
    ].join("\n\n").strip

    @thread.add!(:user, text)
    send_request
  end

  def send_request
    attempt(3) do
      send_chat_action(:typing)

      response = open_ai.chat(
        parameters: {
          model: config.open_ai["chat_gpt_model"],
          messages: @thread.history
        }
      )

      if response["error"]
        error_text = "```#{response["error"]["message"]}```"
        error_text += "\n\nHint: send /restart command to reset the context." if error_text.match? "tokens"
        send_chat_gpt_error(error_text.strip)
      else
        text = response.dig("choices", 0, "message", "content")
        puts "#{Time.now.utc} | Chat ID: #{@chat.id}, tokens used: #{response.dig("usage", "total_tokens")}"

        send_chat_gpt_response(text)
      end
    end
  end

  def send_chat_gpt_error(text)
    reply(text, parse_mode: "Markdown")
  end

  def send_chat_gpt_response(text)
    reply(text)
    @thread.add!(:assistant, text)
  end

  def add_name(name, text)
    return "" if text.nil? || text.empty?

    "<#{name}>:\n#{text}"
  end
end
