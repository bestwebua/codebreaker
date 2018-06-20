module Codebreaker
  module Motivation
    private
    def message_is_allowed?
      !game.won? && game.attempts == rand(1..game.configuration.max_attempts)
    end

    def motivation_message(msg)
      return unless message_is_allowed?
      msg
    end
  end
end
