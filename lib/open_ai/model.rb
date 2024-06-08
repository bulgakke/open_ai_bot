module OpenAI
  class Model
    # All prices are per 1K tokens
    MODEL_INFO = {
      "gpt-4o": {
        max_context: 128_000,
        prompt_price: 0.005,
        completion_price: 0.015,
        vision_price: 0.005
      },
      "gpt-3.5-turbo": {
        max_context: 16385,
        prompt_price: 0.0005,
        completion_price: 0.0015,
        vision_price: 0
      }
    }

    attr_accessor :max_context, :prompt_price, :completion_price, :vision_price

    [:max_context, :prompt_price, :completion_price, :vision_price].each do |attr|
      define_method(attr) do
        MODEL_INFO[@model][attr]
      end
    end

    def initialize(model)
      if MODEL_INFO[model].nil?
        raise ArgumentError.new("Unknown model: #{model.inspect}.")
      end

      @model = model
    end

    def to_s
      @model
    end

    def has_vision?
      MODEL_INFO[@model][:vision_price].positive?
    end

    def request_cost(prompt_tokens:, completion_tokens:, vision_tokens:, current_thread:)
      prompt_cost     = prompt_tokens * prompt_price / 1000
      completion_cost = completion_tokens * completion_price / 1000
      vision_cost     = vision_tokens * vision_price / 1000

      total = prompt_cost + completion_cost + vision_cost
      thread_total = current_thread.total_cost

      info = "\n\n" + {
        prompt: "#{prompt_tokens} tokens (#{prompt_cost.round(5)}$)",
        completion: "#{completion_tokens} tokens (#{completion_cost.round(5)}$)",
        vision: "#{vision_tokens} tokens (#{vision_cost.round(5)}$)",
        total: "#{total.round(5)}$",
        total_for_this_conversation: "#{(thread_total + total).round(5)}$",
        max_context: max_context
      }.map { |k, v|
        "#{k}: #{v}"
      }.join("\n")

      { info:, total: }
    end
  end
end