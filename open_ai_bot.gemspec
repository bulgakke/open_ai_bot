# frozen_string_literal: true

require "rubydium"
require_relative "lib/open_ai_bot"

require_relative "lib/ext/blank"
require_relative "lib/ext/in"

Gem::Specification.new do |spec|
  spec.name          = "open_ai_bot"
  spec.version       = "0.3.5"
  spec.authors       = ["bulgakke"]
  spec.email         = ["vvp835@yandex.ru"]

  spec.summary       = "Telegram bot for using ChatGPT, DALL-E and Whisper"
  # spec.description   = "TODO: Write a longer description or delete this line."
  spec.homepage      = "https://github.com/bulgakke/open_ai_bot"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bulgakke/open_ai_bot"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"

  {
    "down" => ["~> 5.4"],
    "http" => ["~> 5.1"],
    "nokogiri" => ["~> 1.15"],
    "rubydium" => [">= 0.2.5"],
    "ruby-openai" => ["~> 5.1"]
  }.each do |name, versions|
    spec.add_dependency(name, *versions)
  end
end
