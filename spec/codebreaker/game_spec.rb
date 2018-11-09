require 'spec_helper'

module Codebreaker
  RSpec.describe GameConfiguration do
    describe '#initialize' do
      context 'new object' do
        it 'be child of Struct' do
          expect(subject.class.superclass).to eq(Struct)
        end
      end
    end
  end

  RSpec.describe Game do
    let(:game) do
      Game.new do |config|
        config.player_name = 'Mike'
        config.max_attempts = 5
        config.max_hints = 2
        config.level = Game::SIMPLE_LEVEL
        config.lang = :en
      end
    end

    let(:message) { game.instance_variable_get(:@locale).localization }

    describe '#new' do
      context 'without block or params' do
        specify do
          expect { subject }.to raise_error(RuntimeError, message['errors']['fail_configuration'])
        end
      end

      context 'with block or params' do
        describe 'with wrong params' do
          context 'max_attempts, max_hints not integers' do
            let(:not_integers) { Game.new('Mike', '5', '2', Game::SIMPLE_LEVEL, :en) }

            specify do
              expect { not_integers }.to raise_error(RuntimeError, message['errors']['fail_configuration_values'])
            end
          end

          context 'max_attempts < 1' do
            let(:max_attempts) { Game.new('Mike', 0, 2, Game::SIMPLE_LEVEL, :en) }

            specify do
              expect { max_attempts }.to raise_error(RuntimeError, message['errors']['fail_configuration_values'])
            end
          end

          context 'max_hints negative' do
            let(:max_hints) { Game.new('Mike', 1, -1, Game::SIMPLE_LEVEL, :en) }

            specify do
              expect { max_hints }.to raise_error(RuntimeError, message['errors']['fail_configuration_values'])
            end
          end

          context 'unknown level' do
            let(:unknown_level) { Game.new('Mike', 1, -1, :nonexistent_level, :en) }

            specify do
              expect { unknown_level }.to raise_error(RuntimeError, message['errors']['unknown_level'])
            end
          end
        end

        describe '#configuration' do
          let(:instance_methods) { GameConfiguration.instance_methods(all = false) }

          it 'GameConfiguration struct object' do
            expect(game.configuration).to be_an_instance_of(GameConfiguration)
          end

          it 'immutable object' do
            expect(game.configuration.frozen?).to be(true)
          end

          it 'has necessary instance methods' do
            expect(instance_methods).to include(:player_name, :max_attempts, :max_hints, :level, :lang)
          end
        end

        context '#initialize' do
          describe 'should load localization object into instance var' do
            specify { expect(game.instance_variable_get(:@locale)).to be_an_instance_of(Localization) }
          end

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

            specify { expect(secret_code).to be_an_instance_of(Array) }

            it 'has secret code' do
              expect(secret_code).not_to be_empty
            end

            it 'consists only 4 digits in range 1..6' do
              expect(secret_code.join).to match(/\A[1-6]{4}\z/)
            end
          end
        end

        describe '#guess_valid?' do
          it 'accepts string only' do
            expect { game.guess_valid?(1) }.to raise_error(RuntimeError, message['errors']['invalid_input'])
          end

          it 'include digits only' do
            expect { game.guess_valid?('1a') }.to raise_error(RuntimeError, message['alerts']['invalid_input'])
          end

          it 'consists of 4 digis in range 1..6' do
            expect(game.guess_valid?('2416')).to be(true)
          end
        end

        describe '#to_guess' do
          describe '#to_guess actions' do
            context 'when attempts are available' do
              it 'reduce attempts by one' do
                expect { game.to_guess('1111') }.to change { game.attempts }.from(5).to(4)
              end
            end

            context 'when method was called' do
              before { game.instance_variable_set(:@secret_code, [1, 2, 3, 4]) }

              it 'result should be changed' do
                expect(game.to_guess('1234')).not_to be_empty
              end
            end

            context 'when no attempts left' do
              before { game.instance_variable_set(:@attempts, 0) }

              specify do
                expect { game.to_guess('1111') }.to raise_error(RuntimeError, message['alerts']['no_attempts'])
              end
            end
          end

          describe '#fancy_algo' do
            before { game.instance_variable_set(:@secret_code, [1, 2, 6, 4]) }

            context 'guess item was equal secret item in the same position' do
              let(:guessed_items_sp_1) { game.to_guess('1264') }
              let(:guessed_items_sp_2) { game.to_guess('1255') }

              specify { expect(guessed_items_sp_1).to eq('++++') }
              specify { expect(guessed_items_sp_2).to eq('++  ') }
            end

            context 'guess item was equal secret item in the different position' do
              let(:guessed_items_dp_1) { game.to_guess('2641') }
              let(:guessed_items_dp_2) { game.to_guess('2254') }

              specify { expect(guessed_items_dp_1).to eq('----') }
              specify { expect(guessed_items_dp_2).to eq(' + +') }
            end

            context 'guess item was not equal any secret item' do
              let(:not_guessed_items) { game.to_guess('3333') }
              specify { expect(not_guessed_items).to eq('    ') }
            end

            context 'some random cases' do
              specify { expect(game.to_guess('5552')).to eq('   -') }
              specify { expect(game.to_guess('4664')).to eq('  ++') }
              specify { expect(game.to_guess('6666')).to eq('  + ') }
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
            context 'if nothing guessed before call' do
              let(:secret_code) { game.instance_variable_get(:@secret_code) }

              it 'returns one of 4 secret digits' do
                expect(secret_code).to include(game.hint)
              end
            end

            context 'when something guessed' do
              before do
                game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
                game.instance_variable_set(:@result, '+++ ')
              end

              it 'returns one of not guessed numbers' do
                expect(game.hint).to eq(4)
              end
            end
          end

          context 'when no hints left' do
            before { game.instance_variable_set(:@hints, 0) }

            specify do
              expect { game.hint }.to raise_error(RuntimeError, message['alerts']['no_hints'])
            end
          end
        end

        describe '#score' do
          describe 'levels' do
            before { game.instance_variable_set(:@configuration, game.configuration.dup) }

            let(:get_score) do
              game.instance_variable_set(:@attempts, 0)
              game.instance_variable_set(:@hints, 0)
              game.score
            end

            describe 'nothing guessed' do
              context 'simple' do
                specify { expect(get_score).to be_zero }
              end

              context 'middle' do
                before { game.configuration.level = Game::MIDDLE_LEVEL }
                specify { expect(get_score).to eq(-40) }
              end

              context 'hard' do
                before { game.configuration.level = Game::HARD_LEVEL }
                specify { expect(get_score).to eq(-200) }
              end
            end

            describe 'one or more guessed' do
              before { game.instance_variable_set(:@result, '+   ') }

              context 'simple' do
                specify { expect { get_score }.to change { game.score }.from(0).to(50) }
              end

              context 'middle' do
                before { game.configuration.level = Game::MIDDLE_LEVEL }
                specify { expect { get_score }.to change { game.score }.from(0).to(60) }
              end

              context 'hard' do
                before { game.configuration.level = Game::HARD_LEVEL }
                specify { expect { get_score }.to change { game.score }.from(0).to(50) }
              end
            end
          end

          describe 'bonus points' do
            before { game.instance_variable_set(:@result, '++++') }

            context 'when guessed from first attempt' do
              let(:from_first_attempt) { game.instance_variable_set(:@attempts, 4); game.score }
              specify { expect { from_first_attempt }.to change { game.score }.from(0).to(540) }
            end

            context 'when guessed and have used more then one attempts' do
              let(:from_n_attempts) { game.instance_variable_set(:@attempts, 3); game.score }
              specify { expect { from_n_attempts }.to change { game.score }.from(0).to(80) }
            end
          end
        end
      end
    end
  end
end
