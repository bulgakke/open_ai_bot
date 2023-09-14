## Ruby
(`ruby -v` should return something, preferrably > 3.2)

Example for Ubuntu, bash and asdf:

```bash
sudo apt install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.2.2
echo 'ruby 3.2.2' > ~/.tool-versions
```

## Telegram Bot API token
1. Go to t.me/BotFather
2. Create a bot with /newbot
3. Put obtained API token into config.yaml
3. In bot settings, go to Group Privacy -> Turn off (make sure it's **disabled**)

## OpenAI API token
1. Go to https://platform.openai.com/account/api-keys
2. Give them money
3. Create new secret key
4. Put it into config.yaml
5. You can also put organizatino ID in there if you want (uncomment respective line in main.rb)

## Other
Put @usernames of your bot and your main account into config.yaml

## Install dependencies
`bundle`

## Run
`ruby main.rb gptbot`
