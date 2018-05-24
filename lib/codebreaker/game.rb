module Codebreaker
  GameConfiguration = Struct.new(:player_name, :max_attempts, :max_hints, :level, :lang)

  class Game
    BONUS_POINTS, ZERO_POINTS = 200, 0

    attr_reader :attempts, :hints, :configuration

    def initialize
      @locale = Localization.new(:game)
      @configuration ||= GameConfiguration.new
      yield @configuration if block_given?
      apply_configuration
      generate_secret_code
    end

    def guess_valid?(input)
      raise message['errors']['invalid_input'] unless input.is_a?(String)
      !!input[/\A[1-6]{4}\z/]
    end

    def to_guess(input)
      raise message['alerts']['no_attempts'] if attempts.zero?
      @attempts -= 1
      @result = fancy_algo(input, @secret_code)
    end

    def won?
      @result == '++++'
    end

    def hint # need to add range current position
      raise message['alerts']['no_hints'] if hints.zero?
      @hints -= 1
      @secret_code.sample
    end

    def score
      calculate_score
    end

    private

    def apply_configuration
      raise message['errors']['fail_configuration'] if configuration.any?(&:nil?)
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
          when item == secret_code[index] then '+'
          when secret_code[index..-1].include?(item) then '-'
          else ' '
        end
      end
      result.join
    end

    def calculate_score
      level_rates = case configuration.level
        when :simple then [10, 0]
        when :middle then [20, 20]
        when :hard then [50, 30]
        else raise message['errors']['unknown_level']
      end

      attempt_rate, hint_rate = level_rates
      used_attempts = configuration.max_attempts - attempts
      used_hints = configuration.max_hints - hints
      bonus_points = won? ? BONUS_POINTS : ZERO_POINTS

      used_attempts*attempt_rate - used_hints*hint_rate + bonus_points
    end
  end
end
