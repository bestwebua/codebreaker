module Codebreaker
  class Processor
    def initialize(guess, secret_code)
      @result ||= fancy_algo(guess, secret_code)
    end

    def get_result
      @result.join
    end

    private

    def fancy_algo(guess, secret_code)
      guess.chars.map(&:to_i).map.with_index do |item, index|
        case
          when item == secret_code[index] then '+'
          when secret_code[index..-1].include?(item) then '-'
          else ''
        end
      end
    end
  end
end
