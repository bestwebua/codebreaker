module Codebreaker
  GameConfiguration = Struct.new(:player_name, :max_attempts, :max_hints, :level, :lang)

  class Game
    include GameConst
    include Message

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
      @result = fancy_algo(input, secret_code)
    end

    def won?
      result == RIGHT_ANSWER * 4
    end

    def hint
      raise message['alerts']['no_hints'] if hints.zero?
      @hints -= 1
      return secret_code.sample if result.empty?
      not_guessed = result.chars.map.with_index do |item, index|
        secret_code[index] unless item == RIGHT_ANSWER
      end
      not_guessed.compact.sample
    end

    def score
      calculate_score
    end

    private

    def check_configuration
      raise message['errors']['fail_configuration'] if configuration.any?(&:nil?)
      begin
        raise if configuration.max_attempts < 1 || configuration.max_hints.negative?
      rescue
        raise message['errors']['fail_configuration_values']
      end
    end

    def create_instance_vars
      @attempts = configuration.max_attempts
      @hints = configuration.max_hints
      @locale.lang = configuration.lang
      @result = ''
    end

    def apply_configuration
      check_configuration
      configuration.freeze
      create_instance_vars
    end

    def result
      @result
    end

    def generate_secret_code
      @secret_code = (1..4).map { rand(1..6) }
    end

    def secret_code
      @secret_code
    end

    def fancy_algo(guess, secret_code)
      guess.chars.map(&:to_i).map.with_index do |item, index|
        case
          when item == secret_code[index] then RIGHT_ANSWER
          when secret_code[index..-1].include?(item) then RIGHT_ANSWER_DIFF_INDEX
          else WRONG_ANSWER
        end
      end.join
    end

    def calculate_score
      level_rates = case configuration.level
        when SIMPLE_LEVEL then [TEN_POINTS, ZERO_POINTS]
        when MIDDLE_LEVEL then [TWENTY_POINTS, TWENTY_POINTS]
        when HARD_LEVEL   then [FIFTY_POINTS, ONE_HUNDRED_POINTS]
        else raise message['errors']['unknown_level']
      end

      attempt_rate, hint_rate = level_rates
      guessed = result.count(RIGHT_ANSWER)

      used_attempts = configuration.max_attempts - attempts
      used_hints = configuration.max_hints - hints
      bonus_points = won? && used_attempts == 1 ? BONUS_POINTS : ZERO_POINTS

      used_attempts * attempt_rate * guessed - used_hints * hint_rate + bonus_points
    end
  end
end
