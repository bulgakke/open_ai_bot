require 'telegram/bot'

Telegram::Bot::Client.run("1043894792:AAGC_oA2Ztvo5bBZBPxX5_oUxFX-L_obZJI") do |client|
  client.listen do |update|
    print '|'
  end
end
