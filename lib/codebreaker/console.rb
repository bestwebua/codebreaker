require 'colorize'

module Codebreaker
  class Console
    attr_reader :game

    def initialize(game)
      @game = game
      @game_config_snapshot = game.configuration.clone
      @locale = Localization.new(:console, game.configuration.lang)
    end

    def start_game
      puts ' :::: Codebreaker Console Game :::: '.colorize(:background => :blue)
      puts 'Use \'-h\' for help.'
      submit_answer
    end

    def submit_answer
      puts 'Enter your guess:'
      input = gets.chomp
      show_hint if input == '-h'
      input_validator(input)
      process(input)
    end

    def input_validator(input)
      #until game.guess_valid?(input)
        begin
          game.guess_valid?(input)
        rescue => error
          error.to_s.red
        end
      #end
    end

    # to del
    def invalid_answer
      puts 'Answer should equal 4 digits in range from 1 to 6!'.red
      submit_answer
    end

    def show_hint
      puts begin
        game.hint.to_s.green
      rescue => error
        error.to_s.red
      end
    end

    def process(input)
      puts game.to_guess(input)
      game.won? ? finish_game : continue_the_game
    end

    def continue_the_game
      finish_game if game.attempts.zero?
      submit_answer
    end

    def finish_game
      puts game.won? ? 'You win :)'.green : 'You lost :('.red
      save_game
      new_game
    end

    def input_selector
      input = ''
        until %w(y n).include?(input)
          print ' (y/n):'
          input = gets.chomp
        end
      input == 'y'
    end

    def save_game
      print 'Do you whant to save your score?'
      'save game' if input_selector
    end

    def new_game
      print 'Do you whant to play again?'

      if input_selector
        load_new_game
        start_game
      else
        puts 'Exit...'
      end

    end

    def load_new_game
      @game = Game.new do |config|
        @game_config_snapshot.each_pair do |key, value|
          config[key] = value
        end
      end
    end


  end
end
