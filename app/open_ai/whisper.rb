# frozen_string_literal: true

module Whisper
  def transcribe
    if !allowed_chat?
      if chat_not_allowed_message
        return reply(chat_not_allowed_message, parse_mode: "Markdown")
      else
        return
      end
    end

    attempt(3) do
      voice =
        if @command == "/transcribe"
          @replies_to&.voice
        else
          @msg.voice
        end

      return unless voice

      send_chat_action(:typing)

      file = ogg_to_mp3(download_file(voice))
      response = send_whisper_request(file[:file])

      if response["error"]
        reply_code(response["error"])
      else
        reply(response["text"])
      end
    ensure
      FileUtils.rm_rf(file[:names]) if file
    end
  end

  def ogg_to_mp3(file)
    ogg = file.original_filename
    mp3 = ogg.sub(/og.\z/, "mp3")
    `ffmpeg -i ./#{ogg} -acodec libmp3lame ./#{mp3} -y`
    { file: File.open("./#{mp3}", "rb"), names: [ogg, mp3] }
  end

  def send_whisper_request(file)
    open_ai.audio.transcribe(
      parameters: {
        model: "whisper-1",
        file: file
      }
    )
  end
end
