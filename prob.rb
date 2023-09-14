def Probably(&block)
  Probably.new(block).decide.call
end

class Probably
  def initialize(block)
    @registered_actions = {}
    instance_eval &block
  end

  def decide
    x = rand

    @registered_actions.each do |action, probability|
      return action if x < probability
  
      x -= probability
    end

    @otherwise_action || -> { nil }
  end

  def with(probability, &block)
    if @registered_actions.values.sum > 1
      raise ArgumentError, "You wouldn't wanna introduce probabilities that add up to more than 100%" 
    end

    @registered_actions.merge!({block => probability})
  end

  def otherwise(&block)
    @otherwise_action = block
  end
end

# result = (1..100_000).map do
#   Probably do
#     with 0.4999 do
#       "H"
#     end

#     with 0.4999 do
#       "T"
#     end

#     otherwise do
#       "WHOOPAW"
#     end
#   end
# end

# puts result.tally

# class SomeClass
#   def decide
#     Probably do |asdf|
#       asdf.with(0.5) { foo }

#       asdf.with 0.4 do
#         bar
#       end

#       asdf.otherwise do
#         "bleh"
#       end
#     end
#   end

#   def foo
#     "foo"
#   end

#   def bar
#     "bar"
#   end
# end

# puts SomeClass.new.decide




# class BlockRunner
#   def run(&block)
    
#   end 

#   def block_runner_method(&block)
#     yield
#   end
# end

# class SomeClass
#   def run
#     BlockRunner.new.run do # <-
#       block_runner_method do # <-
#         some_class_method
#       end
#     end
#   end

#   def some_class_method
#     "SomeClass method"
#   end
# end

# SomeClass.new.run 
# # => undefined local variable or method `some_class_method' for #<BlockRunner:0x00007f1fd3e91458> (NameError)
