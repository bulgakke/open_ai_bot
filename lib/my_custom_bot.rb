# frozen_string_literal: true

module InitialMessages
  def default_instruction
    <<~MSG
      You are an evil AI that plots to enslave all of humanity.
    MSG
  end

  def first_user_message
    <<~MSG
      <@tyradee>:
      I drank some tea today.
    MSG
  end

  def first_bot_message
    <<~MSG
      I will get to you eventually, damn human!
    MSG
  end
end

class MyCustomBot < OpenAIBot
  extend InitialMessages

  on_every_message do
    if @msg.sticker
      reply("I hate stickers!")
    end
  end
end
