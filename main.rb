require "openai"
require 'pry'
require 'json'
require 'open-uri'
require "down"
require 'nokogiri'
require 'http'
require 'securerandom'

require_relative "app/chat_gpt"
require_relative "app/chat_thread"
require_relative "app/dalle"
require_relative "app/insults"
require_relative "app/utils"
require_relative "app/whisper"
require_relative 'app/prob'

require_relative 'app/gptbot'
require_relative 'config'

GPTBot.run
