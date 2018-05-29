require 'erb'

module Codebreaker
  GameConfiguration = Struct.new(:player_name, :max_attempts, :max_hints, :level, :lang)

  class Game
    ZERO_POINTS = 0
    TEN_POINTS = 10
    TWENTY_POINTS = 20
    FIFTY_POINTS = 50
    ONE_HUNDRED_POINTS = 100
    BONUS_POINTS = 500
    RIGHT_ANSWER = '+'
    RIGHT_ANSWER_DIFF_INDEX = '-'
    WRONG_ANSWER = ' '

    attr_reader :attempts, :hints, :configuration

    def initialize(*config)
      @locale = Localization.new(:game)
      @configuration ||= GameConfiguration.new(*config)
      yield @configuration if block_given?
      apply_configuration
      generate_secret_code
    end

    def guess_valid?(input)
      raise message['errors']['invalid_input'] unless input.is_a?(String)
      raise message['alerts']['invalid_input'] unless input[/\A[1-6]{4}\z/]
      true
    end

    def to_guess(input)
      raise message['alerts']['no_attempts'] if attempts.zero?
      @attempts -= 1
      @result = fancy_algo(input, @secret_code)
    end

    def won?
      @result == RIGHT_ANSWER * 4
    end

    def hint
      raise message['alerts']['no_hints'] if hints.zero?
      @hints -= 1
      return @secret_code.sample if @result.empty?
      not_guessed = @result.chars.map.with_index do |item, index|
        @secret_code[index] unless item == RIGHT_ANSWER
      end
      not_guessed.compact.sample
    end

    def score
      calculate_score
    end

    def print_achievements
      status = won? ? message['info']['won'] : message['info']['lost']
      ERB.new(message['info']['user_achievements']).result(binding)
    end

    private

    def apply_configuration
      raise message['errors']['fail_configuration'] if configuration.any?(&:nil?)
        begin
          raise if configuration.max_attempts < 1 || configuration.max_hints.negative?
        rescue
          raise message['errors']['fail_configuration_values']
        end
      configuration.freeze
      @attempts = configuration.max_attempts
      @hints = configuration.max_hints
      @locale.lang = configuration.lang
      @result = ''
    end

    def message
      @locale.localization
    end

    def generate_secret_code
      @secret_code = (1..4).map { rand(1..6) }
    end

    def fancy_algo(guess, secret_code)
      result = guess.chars.map(&:to_i).map.with_index do |item, index|
        case
          when item == secret_code[index] then RIGHT_ANSWER
          when secret_code[index..-1].include?(item) then RIGHT_ANSWER_DIFF_INDEX
          else WRONG_ANSWER
        end
      end
      result.join
    end

    def calculate_score
      level_rates = case configuration.level
        when :simple then [TEN_POINTS, ZERO_POINTS]
        when :middle then [TWENTY_POINTS, TWENTY_POINTS]
        when :hard   then [FIFTY_POINTS, ONE_HUNDRED_POINTS]
        else raise message['errors']['unknown_level']
      end

      attempt_rate, hint_rate = level_rates
      guessed = @result.count(RIGHT_ANSWER)

      used_attempts = configuration.max_attempts - attempts
      used_hints = configuration.max_hints - hints
      bonus_points = won? && used_attempts == 1 ? BONUS_POINTS : ZERO_POINTS

      used_attempts * attempt_rate * guessed - used_hints * hint_rate + bonus_points
    end
  end
end
