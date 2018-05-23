module Codebreaker
  GameConfiguration = Struct.new(:player_name, :attempts, :hints, :level)

  class Game
    attr_reader :attempts, :hints, :configuration

    def initialize
      @configuration ||= GameConfiguration.new
      yield @configuration if block_given?
      apply_configuration
      generate_secret_code
    end

    def guess_valid?(input)
      input.is_a?(String) && !!input[/[1-6]{4}/]
    end

    def to_guess(input)
      raise 'Oops, no attempts left!' if attempts.zero?
      @attempts -= 1
      @result = fancy_algo(input, @secret_code)
    end

    def won?
      @result == '++++'
    end

    def hint # need to add range current position
      raise 'Oops, no hints left!' if hints.zero?
      @hints -= 1
      @secret_code.sample
    end

    def score
      calculate_score
    end

    private

    def apply_configuration
      raise 'The configuration is incomplete' if configuration.any?(&:nil?)
      configuration.freeze
      @attempts = configuration.attempts
      @hints = configuration.hints
      @result = ''
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
      end

      attempt_rate, hint_rate = level_rates
      used_attempts = configuration.attempts - attempts
      used_hints = configuration.hints - hints
      bonus_points = won? ? 200 : 0

      used_attempts*attempt_rate - used_hints*hint_rate + bonus_points
    end
  end
end
