# frozen_string_literal: true

module OpenAI
  module Utils
    def attempt(times, exception=Net::ReadTimeout)
      retries ||= 0
      yield
    rescue exception => e
      retries += 1
      if retries < times
        retry
      else
        reply(e.message, parse_mode: "Markdown")
      end
    end

    def download_file(voice, dir=nil)
      file_path = @api.get_file(file_id: voice.file_id)["result"]["file_path"]

      url = "https://api.telegram.org/file/bot#{config.token}/#{file_path}"

      file = Down.download(url)
      dir ||= "."

      FileUtils.mkdir(dir) unless Dir.exist? dir
      FileUtils.mv(file.path, "#{dir.delete_suffix("/")}/#{file.original_filename}")
      file
    end
  end
end
