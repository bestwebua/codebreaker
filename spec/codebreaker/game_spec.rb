require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    let(:game) do
      Game.new do |config|
        config.player_name = 'Mike'
        config.attempts = 5
        config.hints = 2
        config.level = :simple
      end
    end

    describe '#new' do
      context 'without block' do
        it 'returns RuntimeError' do
          expect {subject}.to raise_error(RuntimeError, 'The configuration is incomplete')
        end
      end

      context 'with block' do
        describe '#configuration' do
          let(:instance_methods) { GameConfiguration.instance_methods(all=false).sort }

          it 'GameConfiguration stuct object' do
            expect(game.configuration).to be_an_instance_of(GameConfiguration)
          end

          it 'immutable object' do
            expect(game.configuration.frozen?).to be(true)
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

          describe '#result' do
            specify { expect(game.instance_variable_get(:@result)).to be_empty }
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
            expect(game.guess_valid?(1)).to be(false)
          end

          it 'include digits only' do
            expect(game.guess_valid?('1a')).to be(false)
          end

          it 'consists of 4 digis in range 1..6' do
            expect(game.guess_valid?('2416')).to be(true)
          end
        end

        describe '#to_guess' do
          context 'if attempts are available' do
            it 'reduce attempts by one' do
              expect { game.to_guess('1111') }.to change { game.attempts }.from(5).to(4)
            end
          end

          context 'if method was called' do
            before { game.instance_variable_set(:@secret_code, [1, 2, 3, 4]) }

            it 'result may be changed' do
              expect(game.to_guess('1234')).not_to be_empty
            end

            it 'result may not be changed' do
              expect(game.to_guess('6666')).to be_empty
            end
          end

          context 'when no attempts left' do
            before { game.instance_variable_set(:@attempts, 0) }

            it 'raise RuntimeError' do
              expect { game.to_guess('1111') }.to raise_error(RuntimeError, 'Oops, no attempts left!')
            end
          end
        end

        describe '#won?' do
          context 'when result equal ++++' do
            before { game.instance_variable_set(:@result, '++++') }
            specify { expect(game.won?).to be(true) }
          end

          context 'when result not equal ++++' do
            before { game.instance_variable_set(:@result, '+-+-') }
            specify { expect(game.won?).to be(false) }
          end
        end

        describe '#hint' do
          context 'when hints are available' do
            it 'reduce by one' do
              expect { game.hint }.to change { game.hints }.from(2).to(1)
            end
          end

          context 'when hint was called' do
            let(:secret_code) { game.instance_variable_get(:@secret_code) }

            it 'returns one of 4 secret digits' do
              expect(secret_code).to include(game.hint)
            end
          end

          context 'when no hints left' do
            before { game.instance_variable_set(:@hints, 0) }

            it 'raise RuntimeError' do
              expect { game.hint }.to raise_error(RuntimeError, 'Oops, no hints left!')
            end
          end
        end

        describe '#score' do
          before { game.instance_variable_set(:@configuration, game.configuration.dup) }
          let(:get_score) do
              game.instance_variable_set(:@attempts, 0)
              game.instance_variable_set(:@hints, 0)
              game.score
            end

          context 'simple' do
            specify { expect { get_score }.to change { game.score }.from(0).to(50) }
          end

          context 'middle' do
            before { game.configuration.level = :middle }
            specify { expect { get_score }.to change { game.score }.from(0).to(60) }
          end

          context 'hard' do
            before { game.configuration.level = :hard }
            specify { expect { get_score }.to change { game.score }.from(0).to(190) }
          end
        end
      end
    end
  end
end
