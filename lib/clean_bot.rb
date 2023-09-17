# frozen_string_literal: true

class CleanBot < Rubydium::Bot
  on_every_message do
    print "|"
  end
end
