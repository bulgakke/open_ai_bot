# frozen_string_literal: true

module OpenAI
  module ChatGPT
    module ClassMethods
      def threads
        @threads ||= {}
      end

      def new_thread(chat_id, model = nil)
        model ||= config.open_ai["chat_gpt_model"].to_sym
        msgs = config.open_ai["whitelist"].include?(chat_id) ? initial_messages : []
        new_thread = ChatThread.new(msgs, model)
        threads[chat_id] = new_thread
      end

      def default_instruction
        msg = <<~MSG
          You are in a group chat. In the first line of the message, you will receive the name of the user who sent that message.
          Do not sign your messages this way
          Do not use users' names without need (for example, if you are replying to @foo, do not add "@foo" to your message)
          You can still use names to mention other users you're not replying to directly.

          Different languages can be used.
        MSG

        SystemMessage.new(
          body: msg
        )
      end

      def first_user_message
        Message.new(
          from: "@tyradee",
          body: "I drank some tea today."
        )
      end

      def first_bot_message
        BotMessage.new(
          body: "Good for you!"
        )
      end

      def initial_messages
        [
          default_instruction,
          first_user_message,
          first_bot_message
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

    def current_thread
      self.class.threads[@chat.id] || self.class.new_thread(@chat.id)
    end

    def username(user)
      return unless user
      return "@" + user.username if user.username.present?
      return user.first_name if user.first_name.present?

      "NULL"
    end

    def handle_gpt_command
      return unless bot_mentioned? || bot_replied_to? || private_chat?
      return if self.class.registered_commands.keys.any? { @text.include? _1 }

      if !allowed_chat?
        reply(chat_not_allowed_message, parse_mode: "Markdown") if chat_not_allowed_message
        return
      end

      current_message = Message.new(
        id: @message_id,
        replies_to: @replies_to&.message_id,
        from: username(@user),
        body: @text_without_bot_mentions,
        chat_id: @chat.id,
        chat_thread: current_thread,
        image: Image.from_tg_photo(download_file(@msg.photo&.last), model: current_thread.model)
      )

      return unless current_message.valid?

      replies_to =
        if @replies_to && !bot_replied_to?
          Message.new(
            id: @replies_to.message_id,
            replies_to: @replies_to.reply_to_message&.message_id,
            from: username(@target),
            body: @replies_to.text.to_s.gsub(/@#{config.bot_username}\b/, ""),
            chat_id: @chat.id,
            chat_thread: current_thread,
            image: Image.from_tg_photo(download_file(@replies_to.photo&.last), model: current_thread.model)
          )
        else
          nil
        end

      current_thread.add(replies_to)
      current_thread.add(current_message)

      send_request!
    end

    def send_request!
      send_chat_action(:typing)

      response = open_ai.chat(
        parameters: {
          model: current_thread.model.to_s,
          messages: current_thread.as_json
        }
      )

      if response["error"]
        error_text = "```\n#{response["error"]["message"]}```"
        error_text += "\n\nHint: send /restart command to reset the context." if error_text.match? "tokens"
        send_chat_gpt_error(error_text.strip)
      else
        text = response.dig("choices", 0, "message", "content")

        tokens_info = get_tokens_info!(response)

        send_chat_gpt_response(text, tokens_info)
      end
    end

    def send_chat_gpt_error(text)
      reply(text, parse_mode: "Markdown")
    end

    def get_tokens_info!(response)
      completion_tokens = response.dig("usage", "completion_tokens")
      prompt_tokens = response.dig("usage", "prompt_tokens")
      cached_prompt_tokens = response.dig("usage", "prompt_tokens_details", "cached_tokens")

      current_thread.model.request_cost(
        completion_tokens:, prompt_tokens:, cached_prompt_tokens:, current_thread:
      )
    end

    def send_chat_gpt_response(text, tokens_info)
      tokens_text = tokens_info[:info]

      id = reply(text + tokens_text).dig("result", "message_id")

      bot_message = BotMessage.new(
        id: id,
        replies_to: @message_id,
        body: text,
        chat_id: @chat.id,
        chat_thread: current_thread,
        cost: tokens_info[:total]
      )

      current_thread.add(bot_message)
    end
  end
end
