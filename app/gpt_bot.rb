# frozen_string_literal: true

class GPTBot < Rubydium::Bot
  include ChatGPT
  include Dalle
  include Utils
  include Whisper

  on_every_message :handle_gpt_command
  on_every_message :transcribe
  on_every_message :rust
  on_command "/start", :init_session
  on_command "/dalle", :dalle, description: "Sends the prompt to DALL-E"
  on_command "/transcribe", :transcribe
  on_command "/chat_id" do
    reply_code(@chat.id)
  end

  def donate_message
    ""
  end

  def rust
    return unless @msg.text&.match?(/\brust!?\b/i) && (rand < 0.4)

    send_chat_action(:upload_video)
    video = Faraday::UploadIO.new("#{__dir__}/storage/rust.mp4", "mp4")
    send_video(video)
  end

  private

  def private_chat?
    @chat.type == "private"
  end

  def bot_replied_to?
    @target&.username == config.bot_username
  end

  def bot_mentioned?
    @text.split(/\s/).first == "@#{config.bot_username}"
  end

  def open_ai
    config.open_ai_client
  end
end
