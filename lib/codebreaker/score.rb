module Codebreaker
  Score = Struct.new(:date, :player_name, :winner, :level, :score) do
    def initialize
      yield self if block_given?
    end
  end
end
