# frozen_string_literal: true

def Probably(&block)
  Probably.new(block).decide.call
end

class Probably
  def initialize(block)
    @registered_actions = {}
    instance_eval(&block)
  end

  def decide
    x = rand

    @registered_actions.each do |action, probability|
      return action if x < probability

      x -= probability
    end

    @otherwise_action || -> { }
  end

  def with(probability, &block)
    if @registered_actions.values.sum > 1
      raise ArgumentError,
            "You wouldn't wanna introduce probabilities that add up to more than 100%"
    end

    @registered_actions.merge!({ block => probability })
  end

  def otherwise(&block)
    @otherwise_action = block
  end
end
