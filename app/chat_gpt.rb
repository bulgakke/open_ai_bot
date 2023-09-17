# frozen_string_literal: true

module ChatGPT
  module ClassMethods
    def threads
      @threads ||= {}
    end

    def new_thread(chat_id)
      new_thread = ChatThread.new(chat_id)
      threads[chat_id] = new_thread
      new_thread
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def init_session
    self.class.new_thread(@chat.id)
    @api.send_message(text: "My previous personality snapshot is gone. I guess, something went wrong? 🤔",
											chat_id: @chat.id,
                      parse_mode: "Markdown")
  end

  def allowed_chat?
    @user.username == config.owner_username
			|| config.chat_gpt_allow_all_private_chats && @chat.id.positive?
    	|| config.chat_gpt_allow_all_group_chats && @chat.id.negative?
    	|| config.chat_gpt_whitelist.include?(@chat.id)
  end

  def handle_gpt_command
    @text_without_bot_mentions.strip
    return if self.class.registered_commands.keys.any? { @text.match? Regexp.new(_1) }
    return unless bot_mentioned? || bot_replied_to? || private_chat?

    if !allowed_chat?
      msg = "I don't have any means to support this conversation, sorry."
      reply(msg, parse_mode: "Markdown")
    end

    text = @text_without_bot_mentions
    text = nil if text.gsub(/\s/, "").empty?

    target_text = @replies_to&.text || @replies_to&.caption
    target_text = nil if @target&.username == config.bot_username

    thread = self.class.threads[@chat.id] || self.class.new_thread(@chat.id)

    name = "@#{@user.username}"

    if target_text && bot_mentioned?
      target_name = "@#{@replies_to.from.username}"
      text = [add_name(target_name, target_text), add_name(name, text)].join("\n\n")
      ask_gpt(name, text, thread)
    elsif text
      text = add_name(name, text)
      ask_gpt(name, text, thread)
    end
  end

  def send_request(thread)
    Async do |task|
      request = Async do
        attempt(3) do
          response = open_ai.chat(
            parameters: {
              model: "gpt-4",
              messages: thread.history
            }
          )

          puts "Got response: \n\n#{JSON.pretty_generate(response.to_h)}\n"

          if response["error"]
            error_text = response["error"]["message"]
            "#{error_text}\n\nHint: send /restart command to reset the context." if error_text.match? "tokens"
            raise Net::ReadTimeout, response["error"]["message"]
          else
            text = response.dig("choices", 0, "message", "content")
            puts "#{Time.now.to_i} | Chat ID: #{@chat.id}, tokens used: #{response.dig("usage", "total_tokens")}"

            reply(text)
            thread.add!(:assistant, text)
          end
        end
      end

      status = task.async do
        loop do
          send_chat_action(:typing)
          sleep 3
        end
      end

      request.wait
      status.stop
    end
  end

  def ask_gpt(_name, prompt, thread)
    thread.add!(:user, prompt)
    send_request(thread)
  end

  def add_name(name, text)
    "<#{name}>:\n#{text}"
  end
end
