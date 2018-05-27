require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    let(:game) do
      Game.new do |config|
        config.player_name = 'Mike'
        config.max_attempts = 5
        config.max_hints = 2
        config.level = :simple
        config.lang = :en
      end
    end

    describe '#new' do
      context 'without block' do
      specify { expect { subject }.to raise_error(RuntimeError, 'The configuration is incomplete.') }
      end

      context 'with block' do
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

            it 'has 4 digits' do
              expect(secret_code.size).to eq(4)
            end

            it 'consists of digits in range 1..6' do
              expect(secret_code.join).to match(/[1-6]+/)
            end

            it 'consists digits only' do
              expect(secret_code.join).to match(/\A\d+\z/)
            end
          end
        end

        describe '#guess_valid?' do
          it 'accepts string only' do
            expect { game.guess_valid?(1) }.to raise_error(RuntimeError, 'Invalid input type.')
          end

          it 'include digits only' do
            expect { game.guess_valid?('1a') }.to raise_error(RuntimeError, 'Answer should equal 4 digits in range from 1 to 6!')
          end

          it 'consists of 4 digis in range 1..6' do
            expect(game.guess_valid?('2416')).to be(true)
          end
        end

        describe '#to_guess' do
          describe '#to_guess actions' do
            context 'if attempts are available' do
              it 'reduce attempts by one' do
                expect { game.to_guess('1111') }.to change { game.attempts }.from(5).to(4)
              end
            end

            context 'if method was called' do
              before { game.instance_variable_set(:@secret_code, [1, 2, 3, 4]) }

              it 'result should be changed' do
                expect(game.to_guess('1234')).not_to be_empty
              end
            end

            context 'when no attempts left' do
              before { game.instance_variable_set(:@attempts, 0) }
              specify { expect { game.to_guess('1111') }.to raise_error(RuntimeError, 'Oops, no attempts left!') }
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
              specify { expect(guessed_items_dp_1).to eq('--- ') }
              specify { expect(guessed_items_dp_2).to eq('-+ +') }
            end

            context 'guess item was not equal any secret item' do
              let(:not_guessed_items) { game.to_guess('3333') }
              specify { expect(not_guessed_items).to eq('    ') }
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
              it 'should return one of not guessed numbers' do
                expect(game.hint).to eq(4)
              end
            end
          end

          context 'when no hints left' do
            before { game.instance_variable_set(:@hints, 0) }
            specify { expect { game.hint }.to raise_error(RuntimeError, 'Oops, no hints left!') }
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
                before { game.configuration.level = :middle }
                specify { expect(get_score).to eq(-40) }
              end

              context 'hard' do
                before { game.configuration.level = :hard }
                specify { expect(get_score).to eq(-200) }
              end
            end

            describe 'one more guessed' do
              before { game.instance_variable_set(:@result, '+   ') }
              context 'simple' do
                specify { expect { get_score }.to change { game.score }.from(0).to(50) }
              end

              context 'middle' do
                before { game.configuration.level = :middle }
                specify { expect { get_score }.to change { game.score }.from(0).to(60) }
              end

              context 'hard' do
                before { game.configuration.level = :hard }
                specify { expect { get_score }.to change { game.score }.from(0).to(50) }
              end
            end

            context 'unknown' do
              before { game.configuration.level = :unknown }
              specify { expect { get_score }.to raise_error(RuntimeError, 'Unknown game level.') }
            end
          end

          context 'bonus points' do
            let(:get_bonus) { game.instance_variable_set(:@result, '++++'); game.score }
            specify { expect { get_bonus }.to change { game.score }.from(0).to(500) }
          end
        end

        describe '#print_achievements' do
          context 'when lost' do
            specify { expect(game.print_achievements).to eq("User 'Mike' lost the game on 'simple' level with total score 0 points.") }
          end

          context 'when won' do
            before { game.instance_variable_set(:@result, '++++') }
            specify { expect(game.print_achievements).to eq("User 'Mike' won the game on 'simple' level with total score 500 points.") }
          end
        end
      end
    end
  end
end
