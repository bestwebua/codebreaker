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

          describe '#hints' do
            specify { expect(game.hints).to eq(2) }
          end

          describe '#secret_code' do
            let(:secret_code) { game.instance_variable_get(:@secret_code) }

            it 'haves secret code' do
              expect(secret_code).not_to be_empty
            end

            it 'haves 4 digits' do
              expect(secret_code.size).to eq(4)
            end

            it 'consists of digits in range 1..6' do
              expect(secret_code.join).to match(/[1-6]+/)
            end
          end
        end

        describe '#guess_valid?' do
          it 'accepts string only' do
            expect(game.guess_valid?(1)).to eq(false)
          end

          it 'include digits only' do
            expect(game.guess_valid?('1a')).to eq(false)
          end

          it 'consists of 4 digis in range 1..6' do
            expect(game.guess_valid?('2416')).to eq(true)
          end
        end

      end


    end
  end
end