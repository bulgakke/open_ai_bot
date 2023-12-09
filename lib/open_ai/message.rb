module OpenAI
  # An over-engineered solution that ultimately wasn't used for its intent.
  # (ChatGPT isn't brilliant at parsing JSON sructures without starting to reply in JSON, so most of it is useless)

  class Message
    attr_accessor :body, :from, :id, :replies_to, :tokens, :chat_id, :base64_image
    attr_reader :role, :timestamp

    def initialize(**kwargs)
      kwargs.each_pair { public_send("#{_1}=", _2) }
      @role = :user
      @timestamp = Time.now.to_i
    end

    def valid?
      [(base64_image || body), from, id, chat_id].all?(&:present?)
    end

    # Format for OpenAI API
    def as_json
      msg = [from, body].compact.join("\n")

      if base64_image
        {
          role: role,
          content: [
            { type: "text", text: msg },
            { type: "image_url", image_url: { url: "data:image/jpeg;base64,#{base64_image}" } }
          ]
        }
      else
        { role:, content: msg }
      end
    end

    # Format for machine-readable logs
    def for_logs
      { role:, body:, from:, id:, replies_to:, tokens:, chat_id:, timestamp: }
    end

    # Format for human-readable logs
    def to_s
      msg_lines = {
        "Chat ID" => chat_id,
        "Message ID" => id,
        "From" => from,
        "To" => replies_to,
        "Body" => body,
        "Tokens used" => tokens,
        "Image" => (base64_image ? "Some image" : "None")
      }.reject { |_k, v|
        v.blank?
      }.map { |k, v|
        "#{k}: #{v}"
      }

      [Time.now.utc, *msg_lines].join("\n") + "\n\n"
    end
  end

  class SystemMessage < Message
    def initialize(...)
      super(...)
      @role = :system
    end

    def to_s
      [Time.now.utc, "SYSTEM INSTRUCTION", body].join("\n") + "\n"
    end

    def valid?
      body.present?
    end
  end

  class BotMessage < Message
    def initialize(...)
      super(...)
      @role = :assistant
    end

    def valid?
      [body, id, chat_id, tokens].all?(&:present?)
    end
  end
end
