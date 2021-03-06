# codebreaker2018
[![Maintainability](https://api.codeclimate.com/v1/badges/6901f8941feb809fdaf6/maintainability)](https://codeclimate.com/github/bestwebua/codebreaker/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/6901f8941feb809fdaf6/test_coverage)](https://codeclimate.com/github/bestwebua/codebreaker/test_coverage) [![Gem Version](https://badge.fury.io/rb/codebreaker2018.svg)](https://badge.fury.io/rb/codebreaker2018) [![Build Status](https://travis-ci.org/bestwebua/codebreaker.svg?branch=master)](https://travis-ci.org/bestwebua/codebreaker)

Codebreaker is a logic game in which the code-breaker tries to break a secret code created by a code-maker. The code-maker, which will be played by the application we’re going to write, creates a secret code of four numbers between 1 and 6. This is new terminal version of a game represented as Ruby gem.

Codebreaker2018 Rack version: https://github.com/bestwebua/codebreaker-web

## Installation ##

Add this line to your application's Gemfile:

```ruby
gem 'codebreaker2018'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codebreaker2018

## Usage ##
Best way to demonstrate Codebreaker is auto start demo game:

```ruby
require 'codebreaker'
Codebreaker::Console.new
```

### Game features ###
  - Configurator:
    - Player's name
    - Max attempts and hints: integers only
    - Levels: :simple, :middle, :hard
    - Languages: :en, :ru

### Console features ###
  - Autoloading localization by game language
  - Color interface
  - Ability to save results
  - Ability to play again
  - Ability to erase all results
  - Demo mode

### Localization features ###
  - Autoload localizations from locale dir
  - Default language
  - Ability to change locale
  - Ability to use custom locale location

### Score features ###
  - Date
  - Player's name
  - Winner or not
  - Level
  - Score

### Data saving ###
  - Ability to use custom game-data location

### Testing ###
  - RSpec tests have 100% code coverage

### Detail sample of Codebreaker usage ###

```ruby
# Require Codebreaker gem
require 'codebreaker'

# Initialize Game instance with block
game = Codebreaker::Game.new do |config|
  config.player_name = 'Mike'
  config.max_attempts = 5
  config.max_hints = 2
  config.level = :middle
  config.lang = :en
end

# Alternative initialize Game instance with args, args sequence:
# :player_name, :max_attempts, :max_hints, :level, :lang
game = Codebreaker::Game.new('Mike', 5, 2, :middle, :en)

# Init Console instance with your game
console = Codebreaker::Console.new(game)

# Also you can auto load demo game instance and auto start it
Codebreaker::Console.new

# Interactive methods
# Let's play!
console.start_game

# Erase all game statistic
console.erase_scores

# Static methods
# Able to view current game instance into console
console.game

# Able to view path to yml-file
console.storage_path

# Able to view all game statistic
console.scores
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestwebua/codebreaker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
