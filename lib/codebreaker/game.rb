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
      !!input[/[1-6]{4}/]
    end

    def process(input)
      @attempts -= 1
      @result = Processor.new(input, @secret_code).result
    end

    def won?
      @result == '++++'
    end

    def hint
      raise 'Oops, no hints left!' if @hints.zero? 
      @hints -= 1
      @secret_code.sample
    end

    def score
      level_rates = case configuration.level
        when :simple then [10, 0]
        when :middle then [20, 20]
        when :hard then [50, 30]
      end

      attempt_rate, hint_rate = level_rates
      used_attempts = configuration.attempts - attempts
      used_hints = configuration.hints - hints
      bonus = self.won? ? 200 : 0

      used_attempts*attempt_rate - used_hints*hint_rate + bonus
    end

    private

    def apply_configuration
      raise 'The configuration is incomplete' if configuration.any?(&:nil?)
      configuration.freeze
      @attempts = configuration.attempts
      @hints = configuration.hints
    end

    def generate_secret_code
      @secret_code = (1..4).map { rand(1..6) }
    end
  end
end