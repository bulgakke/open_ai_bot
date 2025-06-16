# frozen_string_literal: true

require_relative "open_ai/chat_gpt"
require_relative "open_ai/chat_thread"
require_relative "open_ai/message"
require_relative "open_ai/dalle"
require_relative "open_ai/utils"
require_relative "open_ai/whisper"
require_relative "open_ai/model"
require_relative "open_ai/image"

require_relative "ext/blank"
require_relative "ext/in"

class OpenAIBot < Rubydium::Bot
  include OpenAI::ChatGPT
  include OpenAI::Dalle
  include OpenAI::Utils
  include OpenAI::Whisper

  on_every_message :handle_gpt_command
  on_every_message :handle_model_query
  on_every_message :transcribe

  on_command "/restart", :init_session, description: "Resets ChatGPT session"
  on_command "/dalle", :dalle, description: "Sends the prompt to DALL-E"
  on_command "/transcribe", :transcribe, description: "Reply to a voice message to transcribe it"
  on_command "/help", description: "Sends useful help info" do
    reply(self.class.help_message)
  end
  on_command "/d" do
    return unless @user.username == config.owner_username
    return unless @target&.id.in? [config.bot_id, @user.id]

    current_thread.delete(@replies_to.message_id)
    safe_delete(@replies_to)
    safe_delete(@msg)
  end

  on_command "/model" do
    options = []
    OpenAI::Model::MODEL_INFO.each do |model, info|
      options << [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "#{model} - #{sprintf('%.2f', info[:output_price])}$",
          callback_data: "/set #{model}"
        )
      ]
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: options)
    reply("Select a model:", reply_markup: markup)
  end

  def handle_model_query
    return unless @update.is_a? Telegram::Bot::Types::CallbackQuery
    return unless @update.data.start_with? "/set "
    return unless @user.username == config.owner_username

    model = @update.data.delete_prefix("/set ").to_sym
    return if OpenAI::Model::MODEL_INFO[model].nil?

    text =
      if current_thread.model.to_sym == model
        "Already set to `#{model}`"
      else
        current_thread.model = OpenAI::Model.new(model)
        "Was `#{current_thread.model.to_s}`, now `#{model}`"
      end

    reply(text, parse_mode: "Markdown")
  end

  def allowed_chat?
    return true if @user.username == config.owner_username
    return true if config.open_ai["whitelist"].include?(@chat.id)
    return true if config.open_ai["allow_all_private_chats"] && @chat.id.positive?
    return true if config.open_ai["allow_all_group_chats"] && @chat.id.negative?

    false
  end

  def chat_not_allowed_message
    # Return false/nil (leave method empty) to ignore
    # "This chat (`#{@chat.id}`) is not whitelisted for ChatGPT usage. Ask @#{config.owner_username}."
  end

  def session_restart_message
    "Bot's context reset."
  end

  private

  def private_chat?
    @chat.type == "private"
  end

  def bot_replied_to?
    @target&.username == config.bot_username
  end

  def bot_mentioned?
    @text.split(/\s/).first == "@#{config.bot_username}"
  end

  def open_ai
    config.open_ai_client
  end
end
