# frozen_string_literal: true

module OpenAI
  module Dalle
    def dalle
      return unless allowed_chat?

      attempt(3) do
        puts "Received a /dalle command"
        prompt = @replies_to&.text || @text_without_command
        send_chat_action(:upload_photo)

        puts "Sending request"
        response = open_ai.images.generate(parameters: { prompt: prompt })

        send_chat_action(:upload_photo)

        url = response.dig("data", 0, "url")

        puts "DALL-E finished, sending photo to Telegram..."

        if response["error"]
          reply_code(response)
        else
          send_photo(url, reply_to_message_id: @msg.message_id)
        end
      end
    end
  end
end
