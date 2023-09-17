# frozen_string_literal: true

class ChatThread
  def initialize(defaults = [])
    @history = defaults
    puts @history
  end

  attr_reader :history

  def add!(role, content)
    return if [role, content].any? { [nil, ""].include?(_1) }

    puts content
    @history.push({ role: role, content: content.gsub(/\\xD\d/, "") })
  end
end
