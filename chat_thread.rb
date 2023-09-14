class ChatThread
  def initialize(chat)
    @history = [
      {
        role: :system,
        content: default_instruction,
      },
      {
        role: :user,
        content: first_user_message,
      },
      {
        role: :assistant,
        content: first_bot_message
      }
    ]
  end

  def history
    @history
  end

  def add!(role, content)
    return if [role, content].any? { _1 == nil || _1 == '' }

    @history.push({
      role:, content: content.gsub(/\\xD\d/, '')
    })
  end

  def first_bot_message
    <<~MSG
      Good for you!
    MSG
  end

  def first_user_message
    <<~MSG
      <@tyradee>:

      I drank some tea today.
    MSG
  end

  def default_instruction
    <<~MSG
      Ты находишься в групповом чате. Здесь могут использоваться разные языки, так что отвечай на вопросы на том языке, на котором они заданы.

      Помимо текста сообщений, первой строчкой ты будешь получать имя пользователя, который отправил это сообщение.
      Пользователи могут просить обращаться к ним иначе, чем подписано сообщение.

      Тебе не нужно подписывать свои сообщения и без необходимости вставлять имена других пользователей.

      Если не до конца понимаешь, о чём вопрос - задавай уточняющий вопрос в ответ. Также изредка задавай общие вопросы для продвижения диалога.
    MSG
  end
end
