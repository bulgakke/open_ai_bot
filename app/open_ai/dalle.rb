# frozen_string_literal: true

module Dalle
  def dalle
    if !allowed_chat?
      if chat_not_allowed_message
        return reply(chat_not_allowed_message, parse_mode: "Markdown")
      else
        return
      end
    end

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
