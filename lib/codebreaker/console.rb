require 'colorize'

module Codebreaker
  class Console
    YES = 'y'

    attr_reader :game

    def initialize(game)
      @locale = Localization.new(:console)
      load_console(game)   
    end

    def start_game
      puts message['alerts']['welcome'].colorize(:background => :blue)
      puts message['alerts']['hint_info']
      submit_answer
    end

    #private

    def load_console(game)
      raise ArgumentError, message['errors']['wrong_object'] unless game.is_a?(Game)
      @game = game
      @locale.lang = game.configuration.lang
      @game_config_snapshot = game.configuration.clone
    end

    def message
      @locale.localization
    end

    def submit_answer
      process(user_interaction)
    end

    def show_hint
      puts begin
        "#{message['alerts']['hint']}: #{game.hint.to_s.green}"
      rescue => error
        error.to_s.red
      end
    end

    def user_interaction
      unless game.attempts.zero?
        input, status, step = '', false, 0
        until status
          begin
            game.guess_valid?(input)
            status = true
          rescue => error
            puts error.to_s.red unless step.zero? || input == '-h'
            puts "#{message['alerts']['guess']}:"
            input = gets.chomp
            step += 1
            show_hint if input == '-h'
          end
        end
        input
      end
    end

    def motivation_message
      if !game.won? && game.attempts == rand(1..game.configuration.max_attempts)
        message['alerts']['motivation']
      end
    end

    def process(input)
      begin
        puts game.to_guess(input)
        puts motivation_message
      rescue => error
        puts error.to_s.red
        finish_game
      end
      game.won? ? finish_game : submit_answer
    end

    def finish_game
      puts game.won? ? message['alerts']['win'].green : message['alerts']['lose'].red
      save_game
      new_game
    end

    def input_selector
      input = ''
        until %w(y n).include?(input)
          print " (y/n) #{message['alerts']['yes_or_no']}:"
          input = gets.chomp
        end
      input == YES
    end

    def save_game
      print message['alerts']['save_game']
      save_game_data if input_selector
    end

    def save_game_data
      file = "#{File.expand_path(File.dirname(__FILE__))}/data/users_scores.txt"
      File.open(file, 'a+') do |data|
        data.puts "#{Time.now.strftime('%Y%m%d-%H%M%S')}: #{game.print_achievements}"
      end
      puts message['info']['successfully_saved'].green
    end

    def new_game
      print message['alerts']['new_game']
      if input_selector
        load_new_game
        start_game
      else
        puts message['alerts']['shutdown']
        exit
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
