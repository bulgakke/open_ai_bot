# frozen_string_literal: true

module ConfigMenu
  def self.included(base)
    base.on_every_message :handle_config_query
    base.on_command "/config" do
      $original_config_message_id = @message.id
      $config_message_id = reply("clicky buttons:", reply_markup: config_menu).dig("result", "message_id")
    end
  end

  def model_selection_menu
    options = []
    OpenAI::Model::MODEL_INFO.each do |model, info|
      options << [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "#{model} - #{sprintf('%.2f', info[:output_price])}$",
          callback_data: "/set_model #{model}"
        )
      ]
    end

    options << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "<< Go back",
        callback_data: "/go_back"
      )
    ]

    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: options)
  end

  def config_menu
    buttons = {
      "Select model >>" => "/get_model_menu",
      "Restart" => "/restart",
      "Toggle price info" => "/toggle_price_info",
      "Done" => "/config_done"
    }

    Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: buttons.map { |k, v|
        [Telegram::Bot::Types::InlineKeyboardButton.new(text: k, callback_data: v)]
      }
    )
  end

  def handle_config_query
    return unless @update.is_a? Telegram::Bot::Types::CallbackQuery
    return unless @user.username == config.owner_username

    case @update.data
    when "/get_model_menu"
      @api.edit_message_text(chat_id: @chat.id, message_id: $config_message_id, reply_markup: model_selection_menu, text: "Select model")
    when "/restart"
      init_session
    when "/toggle_price_info"
      if config.respond_to?(:show_price_info)
        config.show_price_info = !config.show_price_info
      else
        config.show_price_info = false
      end
      send_message("Now #{config.show_price_info ? "" : "NOT "}showing price info")
    when "/go_back"
      @api.edit_message_text(chat_id: @chat.id, message_id: $config_message_id, reply_markup: config_menu, text: "Config menu")
    when "/config_done"
      safe_delete_by_id($config_message_id, from_bot: true)
      safe_delete_by_id($original_config_message_id)
    else
      handle_model_query
    end
  end

  def handle_model_query
    return unless @update.is_a? Telegram::Bot::Types::CallbackQuery
    return unless @update.data.start_with? "/set_model "
    return unless @user.username == config.owner_username

    model = @update.data.delete_prefix("/set_model ").to_sym
    return if OpenAI::Model::MODEL_INFO[model].nil?

    text =
      if current_thread.model.to_sym == model
        "Already set to `#{model}`"
      else
        "Was `#{current_thread.model.to_s}`, now `#{model}`"
      end

    current_thread.model = OpenAI::Model.new(model)

    send_message(text, parse_mode: "Markdown")
  end
end
