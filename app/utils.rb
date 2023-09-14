# frozen_string_literal: true

module Utils
  def attempt(times, _exception=StandardError)
    retries ||= 0
    yield
  rescue StandardError => e
    retries += 1
    if retries < times
      retry
    else
      reply_code(e.message)
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
