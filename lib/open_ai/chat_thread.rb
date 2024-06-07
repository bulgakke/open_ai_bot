# frozen_string_literal: true

module OpenAI
  class ChatThread
    def initialize(defaults = [], model = nil)
      model ||= OpenAIBot.config.open_ai["chat_gpt_model"].to_sym
      @history ||= defaults
      @model = model.is_a?(Model) ? model : Model.new(model)
      puts @history
    end

    attr_reader :history
    attr_reader :model

    alias_method :messages, :history

    def delete(id)
      return false unless id

      @history.delete_if { _1.id == id }
      true
    end

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
