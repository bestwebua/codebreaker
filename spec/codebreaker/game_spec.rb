require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    let(:game) do
      Game.new do |config|
        config.player_name = 'Mike'
        config.attempts = 5
        config.hints = 2
        config.level = :middle
      end
    end

    describe '#new' do
      context 'object was created without block' do
        it 'returns RuntimeError' do
          expect {subject}.to raise_error(RuntimeError, 'The configuration is incomplete')
        end
      end

      context 'object was created with block' do
        describe '#configuration' do
          it 'struct object of GameConfiguration' do
            expect(game.configuration).to be_an_instance_of(GameConfiguration)
          end

          it 'immutable' do
            expect(game.configuration.frozen?).to eq(true)
          end
        end

      end


    end
  end
end