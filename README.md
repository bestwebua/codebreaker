# Codebreaker

Codebreaker is a logic game in which the code-breaker tries to break a secret code created by a code-maker. The code-maker, which will be played by the application we’re going to write, creates a secret code of four numbers between 1 and 6.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'codebreaker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codebreaker2018

## Usage
This gem has 2 localizations: english & russian. Keep in mind, language wich used in game configuration will be used in game console interface too. You can expand the gem localizations, just add your own .yml language file into 'lib/codebreaker/locale' folder.

Game features:
  - Configurator:
    - Player's name
    - Max attempts and hints: integers only
    - Levels: :simple, :middle, :hard
    - Languages: :en, :ru

Console features:
  - Autoloading localization by game language
  - Color interface
  - Ability to save results
  - Ability to play again

Localization features:
  - Autoload localizations from locale dir
  - Default language
  - Ability to change locale

If you not configure your config.lang or use nonexistent localization will be used english language by the default.
The sample of usage:

```ruby
# Init Game instance
game = Codebreaker::Game.new do |config|
  config.player_name = 'Mike'
  config.max_attempts = 5
  config.max_hints = 2
  config.level = :middle
  config.lang = :en
end

# Init Console instance with game
console = Codebreaker::Console.new(game)

# Let's play!
console.start_game
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bestwebua/codebreaker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
