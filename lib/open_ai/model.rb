module OpenAI
  class Model
    # All prices are in USD per 1M tokens
    MODEL_INFO = {
      "gpt-4.1": {
        max_context: 1_047_576,
        input_price: 2.00,
        cached_input_price: 0.50,
        output_price: 8.00,
        vision: true
      },
      "gpt-4.1-mini": {
        max_context: 1_047_576,
        input_price: 0.40,
        cached_input_price: 0.10,
        output_price: 1.60,
        vision: true
      },
      "gpt-4.1-nano": {
        max_context: 1_047_576,
        input_price: 0.10,
        cached_input_price: 0.025,
        output_price: 0.40,
        vision: true
      },
      "gpt-4o": {
        max_context: 128_000,
        input_price: 5.00,
        cached_input_price: 2.50,
        output_price: 20.00,
        vision: true
      },
      "gpt-4o-mini": {
        max_context: 128_000,
        input_price: 0.60,
        cached_input_price: 0.30,
        output_price: 2.40,
        vision: true
      },
      "o3": {
        max_context: 200_000,
        input_price: 2.00,
        cached_input_price: 0.50,
        output_price: 8.00,
        vision: true
      },
      "o4-mini": {
        max_context: 200_000,
        input_price: 1.10,
        cached_input_price: 0.275,
        output_price: 4.40,
        vision: true
      }
    }

    [:max_context, :input_price, :cached_input_price, :output_price].each do |attr|
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
      MODEL_INFO[@model][:vision]
    end

    def request_cost(prompt_tokens:, cached_prompt_tokens:, completion_tokens:, current_thread:)
      prompt_cost     = prompt_tokens * input_price / 1_000_000
      cached_prompt_cost = cached_prompt_tokens * cached_input_price / 1_000_000
      completion_cost = completion_tokens * output_price / 1_000_000

      total = prompt_cost + cached_prompt_cost + completion_cost
      thread_total = current_thread.total_cost

      info = "\n\n" + {
        cached_prompt: "#{cached_prompt_tokens} tokens (#{cached_prompt_cost.round(5)}$)",
        uncached_prompt: "#{prompt_tokens} tokens (#{prompt_cost.round(5)}$)",
        completion: "#{completion_tokens} tokens (#{completion_cost.round(5)}$)",
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
