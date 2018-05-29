require 'colorize'
require 'erb'
require 'yaml'

module Codebreaker
  class Console
    HINT = '-h'
    YES = 'y'

    attr_reader :game, :storage_path, :scores

    def initialize(game)
      @locale = Localization.new(:console)
      load_console(game)   
    end

    def start_game
      puts message['alerts']['welcome'].colorize(:background => :blue)
      puts message['alerts']['hint_info']
      submit_answer
    end

    private

    def load_console(game)
      raise ArgumentError, message['errors']['wrong_object'] unless game.is_a?(Game)
      @game = game
      @locale.lang = game.configuration.lang
      @game_config_snapshot = game.configuration.clone
      @storage_path = File.expand_path('./data/scores.yml', File.dirname(__FILE__))
      @scores = load_game_data
    end

    def load_game_data
      YAML.load(File.open(storage_path, 'r')) rescue []
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
            puts error.to_s.red unless step.zero? || input == HINT
            puts "#{message['alerts']['guess']}:"
            input = gets.chomp
            step += 1
            show_hint if input == HINT
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
      summary = game.won? ? message['alerts']['won'].green : message['alerts']['lose'].red
      puts ERB.new(message['info']['results']).result(binding)
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
      save_user_score
      save_to_yml
      puts message['info']['successfully_saved'].green
    end

    def save_user_score
      scores << current_user_score
    end

    def current_user_score
      Score.new do |save|
        save.date = Time.now
        save.player_name = game.configuration.player_name
        save.winner = game.won?
        save.level = game.configuration.level
        save.score = game.score
      end
    end

    def save_to_yml
      File.open(storage_path, 'w') do |file|
        file.write(YAML.dump(scores))
      end
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

    def erase_scores
      print message['alerts']['erase_scores']
      erase_game_data if input_selector
    end

    def erase_game_data
      begin
        File.delete(storage_path)
        scores.clear
        puts message['info']['successfully_erased'].green
      rescue
        puts message['errors']['file_not_found'].red
      end
    end
  end
end
