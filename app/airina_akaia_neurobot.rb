# frozen_string_literal: true

class AirinaAkaiaNeurobot < GPTBot
  on_every_message :react_to_sticker
  on_every_message :rust

  def react_to_sticker
    return unless @msg.sticker

    flip_sticker = lambda do
      return if @msg.sticker.is_video
      return if @msg.sticker.is_animated # ? fix for TGS?

      send_chat_action(:choose_sticker)
      sleep 0.5

      file = download_file(@msg.sticker)

      original = file.original_filename
      flopped = "flopped_#{original}"
      `convert ./#{original} -flop ./#{flopped}`
      sticker = Faraday::UploadIO.new(flopped, original.split(".").last)
      send_sticker(sticker)
    ensure
      FileUtils.rm_rf([original, flopped]) if file
    end

    random_sticker = lambda do
      send_chat_action(:choose_sticker)
      sleep 2
      # Берём название стикерпака
      sticker_pack_name = @msg.sticker.set_name
      # Получаем массив стикеров из него
      stickers = @api.get_sticker_set(name: sticker_pack_name)["result"]["stickers"]
      # Берём рандомный стикер оттуда и его file_id
      random_sticker_id = stickers.sample["file_id"]
      # Отправляем
      send_sticker(random_sticker_id)
    end

    Probably do
      with 0.05, &flip_sticker
      with 0.05, &random_sticker
    end
  end
end
