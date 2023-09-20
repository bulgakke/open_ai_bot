# OpenAI Telegram bot
## What it does
- ChatGPT
  Send any message to the bot, or ping its @username or reply ot its message in a group chat. It will forward your message to ChatGPT and return a response, keeping track of context.
- Whisper
  Record a voice message in any chat with the bot or reply to a forwarded message with the `/transcribe` command. It will reply with a transcript, automatically detecting language(s).
- DALL-e
  Send `/dalle {prompt/description}` command. The bot will reply with a picture based on your prompt.

## Dependencies
1. Ruby (`ruby -v` should return something, preferrably > 3.2)

Example for Ubuntu, bash and asdf:
```bash
sudo apt install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.2.2
echo 'ruby 3.2.2' >> ~/.tool-versions
```

2. `ffmpeg`

## Telegram Bot API token

1. Go to <https://t.me/BotFather>
2. Create a bot with /newbot
3. Put obtained API token into config.yaml
4. In bot settings, go to Group Privacy -> Turn off (make sure it's **disabled**)

## OpenAI API token

1. Go to <https://platform.openai.com/account/api-keys>
2. Give them money
3. Create new secret key
4. Put it into config.yaml
5. You can also put organization ID in there if you want (uncomment respective line in main.rb)

## Other config

- Add @usernames of your bot and your main account
- Fill open_ai.whitelist with allowed group chat ids to your liking. Keep in mind group chat IDs are supposed to be negative. Or set allow_all_group_chats to true
- To learn a chat's id, send any message in that chat with your bot, it will reply with that chat's id if it isn't allowed.

## Adding your own functionality

1. Fork the repo and extend it:
- Create a `MyCustomBot < OpenAIBot` class
- Require the file in `main.rb` and add the class to the `bots` hash

2. Require this project as a dependency:
- Create a new Ruby project
- In the Gemfile, add `gem "open_ai_bot"`
- Inherit your bot class from `OpenAIBot`

## Run

`ruby main.rb`
