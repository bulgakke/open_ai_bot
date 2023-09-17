# frozen_string_literal: true

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

  def download_file(voice)
    file_path = @api.get_file(file_id: voice.file_id)["result"]["file_path"]

    url = "https://api.telegram.org/file/bot#{config.token}/#{file_path}"

    file = Down.download(url)
    FileUtils.mv(file.path, "./#{file.original_filename}")
    file
  end
end
