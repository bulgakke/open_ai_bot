# frozen_string_literal: true

require_relative "open_ai/chat_gpt"
require_relative "open_ai/chat_thread"
require_relative "open_ai/message"
require_relative "open_ai/dalle"
require_relative "open_ai/utils"
require_relative "open_ai/whisper"

class OpenAIBot < Rubydium::Bot
  include OpenAI::ChatGPT
  include OpenAI::Dalle
  include OpenAI::Utils
  include OpenAI::Whisper

  on_every_message :handle_gpt_command
  on_every_message :transcribe

  on_command "/restart", :init_session, description: "Resets ChatGPT session"
  on_command "/dalle", :dalle, description: "Sends the prompt to DALL-E"
  on_command "/transcribe", :transcribe, description: "Reply to a voice message to transcribe it"
  on_command "/help", description: "Sends useful help info" do
    reply(self.class.help_message)
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
