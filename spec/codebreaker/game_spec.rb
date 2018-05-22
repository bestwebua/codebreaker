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
          let(:instance_methods) { GameConfiguration.instance_methods(all=false).sort }

          it 'GameConfiguration stuct object' do
            expect(game.configuration).to be_an_instance_of(GameConfiguration)
          end

          it 'immutable object' do
            expect(game.configuration.frozen?).to eq(true)
          end

          it 'haves necessary instance methods' do
            expect(instance_methods).to eq(%i(attempts attempts= hints hints= level level= player_name player_name=))
          end
        end

        context '#initialize' do
          describe '#attempts' do
            specify { expect(game.attempts).to eq(5) }
          end
        end

      end


    end
  end
end