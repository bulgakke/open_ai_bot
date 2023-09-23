# frozen_string_literal: true

module OpenAI
  class ChatThread
    def initialize(defaults = [])
      @history ||= defaults
      puts @history
    end

    attr_reader :history

    def add(message)
      return false unless message&.valid?
      return false if @history.any? { message.id == _1.id}

      @history << message
      puts message

      true
    end

    def as_json
      @history.map(&:as_json)
    end

    def for_logs
      @history.map(&:for_logs)
    end
  end
end
