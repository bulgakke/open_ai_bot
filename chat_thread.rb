class ChatThread
  def initialize(user)
    @history = [{role: :system, content: default_instruction(user), message_id: -1, chat_id: -1}]
  end

  def history
    @history
  end

  def history_for_api
    @history.map { _1.except(:message_id, :chat_id) }
  end

  def add!(role, content, message_id, chat_id)
    return if [role, content, message_id, chat_id].any? { _1 == nil || _1 == '' }

    @history.push({
      role:, content:, message_id:, chat_id:
    })
  end

  def default_instruction(user)
    name = "#{user.first_name} #{user.last_name} #{user.id}"

    <<~MSG
      <#{name}>:

      Ты в групповом чате.
      Помимо текста сообщений, первой строчкой ты будешь получать имя пользователя, который отправил это сообщение.
      Пользователи могут просить обращаться к ним иначе, чем подписано сообщение.

      Например, это сообщение будет подписано как "#{name}", но ты должен обращаться ко мне как "#{user.first_name}".

      Пользователи также могут обращаться к тебе на других языках, помимо русского.

      В остальном веди себя так, как вёл бы себя в разговоре один-на-один, но учитывая индивидуальный контекст для каждого пользователя.
    MSG
  end
end
