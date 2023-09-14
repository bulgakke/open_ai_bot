# frozen_string_literal: true

require "openai"
require "pry"
require "json"
require "yaml"
require "open-uri"
require "down"
require "nokogiri"
require "http"
require "securerandom"
require "rubydium"

require_relative "app/chat_gpt"
require_relative "app/clean_bot"
require_relative "app/chat_thread"
require_relative "app/dalle"
require_relative "app/insults"
require_relative "app/utils"
require_relative "app/whisper"
require_relative "app/prob"

require_relative "app/gpt_bot"
require_relative "app/bkke_bot"

bots = {
  "bkkebot" => BkkeBot,
  "gptbot" => GPTBot,
  "clean" => CleanBot
}

bot_name = (ARGV & bots.keys).first
bot = bots[bot_name] || BkkeBot

bot.config = YAML.load_file("#{__dir__}/config.yaml")
bot.configure do |config|
  config.open_ai_client = OpenAI::Client.new(
    access_token: config.open_ai_token
    # organization_id: config.open_ai_organization_id
  )
end

if __FILE__ == $PROGRAM_NAME
  command_list = bot.help_message.lines.map { _1.delete_prefix("/") }.join
  puts "Launching #{bot}. Command list: \n\n#{command_list}\n"
  bot.run
end
