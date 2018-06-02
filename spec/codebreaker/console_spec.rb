require 'spec_helper'

module Codebreaker
  RSpec.describe Console do
    before(:context) do
      @current_yml = "#{File.expand_path('../../lib/codebreaker/data/scores.yml', File.dirname(__FILE__))}"
      @temp_yml = "#{File.expand_path('./temp_data/scores.yml', File.dirname(__FILE__))}"
      data_empty = Dir.empty?("#{File.expand_path('../../lib/codebreaker/data/.', File.dirname(__FILE__))}")
      FileUtils.mv(@current_yml, @temp_yml) unless data_empty
    end

    after(:context) do
      temp_empty = Dir.empty?("#{File.expand_path('./temp_data/.', File.dirname(__FILE__))}")
      FileUtils.mv(@temp_yml, @current_yml) unless temp_empty
    end

    subject(:console) do
      game = Codebreaker::Game.new do |config|
        config.player_name = 'Mike'
        config.max_attempts = 5
        config.max_hints = 2
        config.level = :middle
        config.lang = :en
      end
      Codebreaker::Console.new(game)
    end

    let(:message) { console.instance_variable_get(:@locale).localization }

    describe '#initialize' do
      describe 'locale' do
        specify { expect(console.instance_variable_get(:@locale)).to be_an_instance_of(Localization) }
      end

      describe '#load_console' do
        context 'when passed not Game object' do
          let(:with_wrong_object) { Codebreaker::Console.new(Object.new) }
          specify { expect { with_wrong_object }.to raise_error(ArgumentError, 'Wrong object type!') }
        end

        context 'when passed Game object' do
          context 'loaded object' do
            specify { expect(console.game).to be_an_instance_of(Game) }
          end

          context 'console localization should equal to game localization' do
            specify { expect(console.instance_variable_get(:@locale).lang).to eq(console.game.configuration.lang) }
          end

          context 'game configuration snapshot' do
            specify { expect(console.instance_variable_get(:@game_config_snapshot)).to be_an_instance_of(GameConfiguration) }
          end

          context '#storage_path' do
            it 'should be an instance of String' do
              expect(console.storage_path).to be_an_instance_of(String)
            end

            it 'should be a path to yml-file' do
              expect(console.storage_path).to match(/.+scores\.yml\z/)
            end
          end

          describe '#scores' do
            specify { expect(console.scores).to be_an_instance_of(Array) }

            describe '#load_game_data' do
              context 'when no saved data found' do
                specify { expect(console.scores).to be_empty }
              end

              context 'when saved data exists' do
                before do
                  @test_yml = "#{File.expand_path('./test_data/scores.yml', File.dirname(__FILE__))}"
                  FileUtils.mv(@test_yml, @current_yml)
                end

                after { FileUtils.mv(@current_yml, @test_yml) }

                specify { expect(console.scores).to_not be_empty }

                it 'all items should be an instances of Codebreaker::Score' do
                  expect(console.scores.all? { |item| item.is_a?(Score) }).to be(true)
                end
              end
            end
          end
        end
      end
    end

    describe '#start_game' do
      before do
        allow(console).to receive(:submit_answer)
        allow(console).to receive(:puts)
        console.start_game
      end

      after { console.start_game }

      it 'receive welcome message' do
        expect(console).to receive(:puts).with(message['alerts']['welcome'].colorize(:background => :blue))
      end

      it 'receive about hint message' do
        expect(console).to receive(:puts).with(message['alerts']['hint_info'])
      end

      it '#submit_answer call' do
        expect(console).to receive(:submit_answer)
      end
    end

    describe '#submit_answer' do
      before do
        allow(console).to receive(:process)
        allow(console).to receive(:user_interaction)
        console.send(:submit_answer)
      end

      after { console.send(:submit_answer) }

      it '#process call' do
        expect(console).to receive(:process)
      end

      it '#user_interaction call' do
        expect(console).to receive(:user_interaction)
      end
    end

    describe '#show_hint' do
      before do
        allow(console).to receive(:puts)
        console.send(:show_hint)
      end

      after { console.send(:show_hint) }

      context 'when hints still existing' do
        before do
          console.game.instance_variable_set(:@hints, 2)
          console.game.instance_variable_set(:@secret_code, [1, 1, 1, 1])
        end

        let(:console_message) do
          "#{message['alerts']['hint']}: #{console.game.hint.to_s.green}"
        end

        it 'return info message with game hint' do
          expect(console).to receive(:puts).with(console_message)
        end
      end

      context 'when no hints left' do
        before { console.game.instance_variable_set(:@hints, 0) }
        let(:game_hint_error) { console.game.send(:message)['alerts']['no_hints'].red }

        it 'return game hint error' do
          expect(console).to receive(:puts).with(game_hint_error)
        end
      end
    end

    describe '#motivation_message' do
      before do
        console.game.instance_variable_set(:@configuration, console.game.configuration.dup)
        console.game.configuration.max_attempts = 1
      end

      let(:attempts_still_have) { console.game.instance_variable_set(:@attempts, 1); console }
      let(:no_attempts_left) { console.game.instance_variable_set(:@attempts, 0); console }

      context 'when attempts still have' do
        specify { expect(attempts_still_have.send(:motivation_message)).to eq(message['alerts']['motivation']) }
      end

      context 'when no attempts left' do
        specify { expect(no_attempts_left.send(:motivation_message)).to be_nil }
      end
    end

    describe '#user_interaction' do
      it 'need to write a beautiful test'
    end

    describe '#process' do
      it 'need to write a beautiful test'
    end

    describe '#finish_game' do
      before do
        allow(console).to receive(:puts)
        allow(console).to receive(:save_game)
        allow(console).to receive(:new_game)
        console.send(:finish_game)
      end

      after { console.send(:finish_game) }

      describe 'info message' do
        let(:game) { console.game }

        context 'when player wins' do
          let(:summary) { message['alerts']['won'].green }

          it 'return message with score' do
            allow(game).to receive(:won?).and_return(true)
            expect(console).to receive(:puts).with(ERB.new(message['info']['results']).result(binding))
          end
        end

        context 'when player loses' do
          let(:summary) { message['alerts']['lose'].red }

          it 'return message with score' do
            expect(console).to receive(:puts).with(ERB.new(message['info']['results']).result(binding))
          end
        end
      end

      describe 'call methods' do
        it '#save_game' do
          expect(console).to receive(:save_game)
        end

        it '#new_game' do
          expect(console).to receive(:new_game)
        end
      end
    end

    describe '#save_game' do
      before do
        allow(console).to receive(:print)
        allow(console).to receive(:input_selector)
        allow(console).to receive(:save_game_data)
        console.send(:save_game)
      end

      after { console.send(:save_game) }

      it 'return save message alert' do
        expect(console).to receive(:print).with(message['alerts']['save_game'])
      end

      it '#save_game_data call' do
        allow(console).to receive(:input_selector).and_return(true)
        expect(console).to receive(:save_game_data)
      end
    end

    describe '#input_selector' do
      context 'input info message' do
        before do
          allow(console).to receive(:print)
          allow(console).to receive_message_chain(:gets, :chomp).and_return(Codebreaker::Console::YES)
          console.send(:input_selector)
        end

        after { console.send(:input_selector) }

        it 'return y/n alert' do
          expect(console).to receive(:print).with(" (y/n) #{message['alerts']['yes_or_no']}:")
        end
      end

      context 'allow user input' do
        it 'y key should return true' do
          allow(console).to receive(:gets).and_return(Codebreaker::Console::YES)
          expect(console.send(:input_selector)).to be(true)
        end

        it 'other keys should returns false' do
          allow(console).to receive(:gets).and_return('n').once
          expect(console.send(:input_selector)).to be(false)
        end
      end
    end

    describe '#save_game_data' do
      before do
        allow(console).to receive(:puts)
        allow(console).to receive(:save_user_score)
        allow(console).to receive(:save_to_yml)
        console.send(:save_game_data)
      end

      after { console.send(:save_game_data) }

      it 'return successfully save message' do
        expect(console).to receive(:puts).with(message['info']['successfully_saved'].green)
      end

      it '#save_user_score call' do
        expect(console).to receive(:save_user_score)
      end

      it '#save_to_yml call' do
        expect(console).to receive(:save_to_yml)
      end
    end

  end
end
