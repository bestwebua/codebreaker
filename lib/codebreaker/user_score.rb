module Codebreaker
  module UserScore
    private

    def current_user_score
      Score.new do |save|
        save.date = Time.now
        save.player_name = game.configuration.player_name
        save.winner = game.won?
        save.level = game.configuration.level
        save.score = game.score
      end
    end

    def save_user_score
      scores << current_user_score
    end
  end
end
