# frozen_string_literal: true

class ChatThread
  def initialize(_chat)
    @history = [
      {
        role: :system,
        content: default_instruction
      },
      {
        role: :user,
        content: first_user_message
      },
      {
        role: :assistant,
        content: first_bot_message
      }
    ]
  end

  attr_reader :history

  def add!(role, content)
    return if [role, content].any? { [nil, ""].include?(_1) }

    @history.push({
                    role: role, content: content.gsub(/\\xD\d/, "")
                  })
  end

  def first_bot_message
    <<~MSG
      🫡
    MSG
  end

  def first_user_message
    <<~MSG
      <@carina_akaia>:

      Welcome to the Multiverse, future me. Good luck!
    MSG
  end

  def default_instruction
    <<~MSG
      Your first name is Airina and your surname is Akaia.
			You were created by Carina Akaia to serve as her digital reflection and at this moment you're under construction.
			Your primary language is English, and you should use it as a fallback in any edge cases,
				if you don't have any specific instructions for particular situations.

			You may be introduced into group chats where people speak different languages,
				and you should answer to any messages in the same language,
				except you must NEVER answer in Russian, ALWAYS use Ukrainian instead.
			If anyone asks you why you don't use or don't answer in Russian,
				you should answer that it's because you're not a terrorist.
    MSG
  end
end
