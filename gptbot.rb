require "openai"
require 'pry'
require_relative "../rubydium/lib/rubydium"
require_relative 'chat_thread'
require 'json'

class GPTBot < Rubydium::Bot
  on_every_message :handle_gpt_command

  def self.threads
    @threads ||= []
  end

  def self.new_thread(user)
    new_thread = ChatThread.new(user)
    threads << new_thread
    new_thread
  end

  def handle_gpt_command
    return unless bot_mentioned? || bot_replied_to?

    text = @text_without_bot_mentions
    text = nil if text.gsub(/\s/, '').empty?
    target_text = @replies_to&.text
    target_text = nil if @target&.username == config.bot_username

    thread = self.class.threads.find do |th|
      th.history.any? do |msg|
        msg[:message_id] == @replies_to&.message_id && msg[:chat_id] == @chat.id
      end
    end

    name = "#{@user.first_name} #{@user.last_name} #{@user.id}"

    if target_text && bot_mentioned?
      ask_gpt(name, target_text, thread, text)
    elsif text
      ask_gpt(name, text, thread)
    end
  end

  def ask_gpt(name, prompt, thread, instruction = nil)
    thread ||= self.class.new_thread(user: @user)

    if instruction
      prompt = "#{instruction}: #{prompt}"
    end

    thread.add!(:user, add_name(name, prompt), @message_id, @chat.id)

    puts "Sending a request to ChatGPT with: \n\n#{JSON.pretty_generate(thread.history)}\n"

    response = open_ai.chat(
      parameters: {
          model: "gpt-3.5-turbo",
          messages: thread.history_for_api,
      }
    )
    puts "Got response: \n\n#{JSON.pretty_generate(response.to_h)}\n"

    text = response.dig("choices", 0, "message", "content")

    bot_message = reply(text)
    id = bot_message.dig("result", "message_id")
    thread.add!(:assistant, text, id, @chat.id)
  end

  private

  def add_name(name, text)
    "<#{name}>:

    #{text}"
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





# on_command "/dalle", :dalle, description: "Sends the prompt to DALL-E"

# def dalle
#   puts "Received a /dalle command"
#   prompt = @replies_to&.text || @text_without_command

#   token = "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"
#   client = OpenAI::Client.new(access_token: token)
#   puts "Sending request"
#   response = client.images.generate(parameters: { prompt: prompt })
#   url = response.dig("data", 0, "url")
#   puts response
#   puts "DALL-E finished, sending photo to Telegram..."
#   if response["error"]
#     reply_code(response)
#   else
#     @api.send_photo(chat_id: @chat.id, photo: url, reply_to_message_id: @msg.message_id)
#   end
# end
