# frozen_string_literal: true

class BkkeBot < GPTBot
  include Insults

  on_every_message :react_to_sticker
  on_every_message :rust
  on_command "/pry", :pry, description: "Open a debug session (if you have access to the server :3)"
  on_command "/bash", :get_bash_quote
  on_command "/sticker", :convert_to_sticker
  on_command "/twit", :twit

  def twit
    text = @replies_to&.text
    return unless text

    re = /[^a-zа-я0-9\s]/
    text = text.downcase.gsub("ё", "е").gsub(re, " ").gsub(/\s/, " ").squeeze(" ")

    tweet_size = @text_without_command.to_i
    tweet_size = 140 if tweet_size.zero?
    tweet_size = 10_000 if tweet_size >= 10_000
    tweet_size -= 8

    tweets = []
    n = 0
    while n <= (text.size / tweet_size)
      s = 0 + (n * tweet_size)
      e = (tweet_size * (n + 1)) - 1
      tweet = text[s..e]
      tweets << tweet
      n += 1
    end

    total = tweets.size
    tweets.map!.with_index do |t, i|
      "(#{i + 1}/#{total}) " + t
    end

    tweets.each do |t|
      reply(t)
    end
  end

  def convert_to_sticker
    image = @replies_to.photo.last
    # binding.pry
    return reply("Reply to an image") unless image

    file = jpg_to_webp(download_file(image))
    sticker = Faraday::UploadIO.new(file[:names].last, "webp")
    send_sticker(sticker)
    FileUtils.rm_rf(file[:names])
  end

  def donate_message
    <<~MSG
      Донаты на оплату API OpenAI и допиливание бота:

      Tinkoff RUB: `5536 9138 3610 1341`
      XMR: `45pjwRWkEVTHFtH997TKrtBi3kw33kAntau78dpqepfB2v1uF9ScKx8LcQy6gSMn5iGrA2qvuq28P6sTRaUfiuW64DYnaCe`
      BTC: `18nLReEDqtLp2wjHcc6RDw1KVVxvX8Jv2n`
      ETH: `0xA0632c02d89f5b4ac0b6ffc0DbEEDCf43f7599B5`
    MSG
  end

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

  def get_bash_quote
    url = "https://bashorg.org/casual"
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = HTTP.get(url, ssl_context: ctx)
    doc = Nokogiri::HTML(res.body.to_s)
    text = doc.search("div.q").last.children[-2].children.map(&:text).reject(&:empty?).join("\n")
    send_message(text)
  end

  def jpg_to_webp(file)
    jpg = file.original_filename
    webp = jpg.sub(/\..*/, ".webp")
    `convert -resize 512x512 #{jpg} #{webp}`
    { names: [jpg, webp] }
  end

  def pry
    binding.pry
  end
end
