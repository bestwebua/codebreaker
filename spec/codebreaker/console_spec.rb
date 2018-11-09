require 'spec_helper'

module Codebreaker
  RSpec.describe Console do
    before(:context) do
      current_yml = File.expand_path('../../lib/codebreaker/data/scores.yml', File.dirname(__FILE__)).to_s
      @env = RspecFileChef::FileChef.new(current_yml)
      @env.make
    end

    after(:context) do
      @env.clear
    end

    let(:storage_dir) { File.expand_path('../../lib/codebreaker/data', File.dirname(__FILE__)).to_s }
    let(:current_yml) { @env.tracking_files.first }
    let(:test_yml)    { @env.test_files.first }

    subject(:console) do
      game = Codebreaker::Game.new do |config|
        config.player_name = 'Mike'
        config.max_attempts = 5
        config.max_hints = 2
        config.level = Game::MIDDLE_LEVEL
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
            before { console.send(:apply_external_path) }
            after  { console.send(:apply_external_path) }

            it '#apply_external_path call' do
              allow(console).to receive(:apply_external_path)
              expect(console).to receive(:apply_external_path)
            end

            it 'be an instance of String' do
              expect(console.storage_path).to be_an_instance_of(String)
            end

            it 'be a path to yml-file' do
              expect(console.storage_path).to match(/.+scores\.yml\z/)
            end
          end

          describe '#scores' do
            specify { expect(console.scores).to be_an_instance_of(Array) }

            describe '#load_game_data' do
              context 'when no saved data found' do
                before { FileUtils.rm(current_yml) }
                specify { expect(console.scores).to be_empty }
              end

              context 'when saved data exists' do
                before do
                  FileUtils.mv(test_yml, current_yml)
                end

                after { FileUtils.mv(current_yml, test_yml) }

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
        expect(console).to receive(:puts).with(message['alerts']['welcome'].colorize(background: :blue))
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
      let(:msg) { message['alerts']['motivation'] }

      context 'when attempts still have' do
        specify { expect(attempts_still_have.send(:motivation_message, msg)).to eq(message['alerts']['motivation']) }
      end

      context 'when no attempts left' do
        specify { expect(no_attempts_left.send(:motivation_message, msg)).to be_nil }
      end
    end

    describe '#user_interaction' do
      context 'when no attempts left' do
        before { console.game.instance_variable_set(:@attempts, 0) }
        specify { expect(console.send(:user_interaction)).to be_nil }
      end

      context 'when attempts are available' do
        context 'valid input' do
          let(:valid_input) { '1234' }

          before do
            allow(console.game).to receive(:guess_valid?)
            console.send(:user_interaction, valid_input)
          end

          after { console.send(:user_interaction, valid_input) }

          it '#guess_valid? call' do
            expect(console.game).to receive(:guess_valid?)
          end

          it 'returns input' do
            expect(console.send(:user_interaction, valid_input)).to eq(valid_input)
          end
        end

        context 'invalid input' do
          let(:invalid_input) { Console::EMPTY_INPUT }

          before do
            allow(console.game).to receive(:guess_valid?)
            console.send(:user_interaction, invalid_input)
          end

          after { console.send(:user_interaction, invalid_input) }

          it '#guess_valid? call' do
            expect(console.game).to receive(:guess_valid?)
          end

          it 'puts guess message' do
            expect(console.game).to receive(:guess_valid?).and_raise
            allow(console).to receive_message_chain(:gets, :chomp)
            expect(console).to receive(:puts).with("#{message['alerts']['guess']}:").once
          end
        end

        context 'hint input' do
          let(:hint_input) { Console::HINT }

          before do
            allow(console.game).to receive(:guess_valid?)
            console.send(:user_interaction, hint_input)
          end

          after { console.send(:user_interaction, hint_input) }

          it '#show_hint call' do
            expect(console.game).to receive(:guess_valid?).and_raise
            allow(console).to receive(:puts)
            allow(console).to receive_message_chain(:gets, :chomp).and_return(hint_input)
            expect(console).to receive(:show_hint).once
          end
        end
      end
    end

    describe '#process' do
      before do
        console.game.instance_variable_set(:@attempts, 2)
        console.game.instance_variable_set(:@secret_code, [1, 1, 1, 1])
        allow(console).to receive(:puts)
        allow(console).to receive(:finish_game)
        console.send(:process, '1111')
      end

      after { console.send(:process, '1111') }

      context 'when free attempts are available' do
        context 'user was use attempt' do
          it '#to_guess call' do
            expect(console.game).to receive(:to_guess)
          end

          it 'puts marked result' do
            expect(console).to receive(:puts).with(Game::RIGHT_ANSWER * 4)
          end

          it '#motivation_message call' do
            expect(console).to receive(:motivation_message)
          end
        end

        context 'user won' do
          it '#finish_game call' do
            allow(console.game). to receive(:won?).and_return(true)
            expect(console).to receive(:finish_game)
          end
        end

        context 'user not won' do
          it '#submit_answer call' do
            allow(console.game). to receive(:won?).and_return(false)
            expect(console).to receive(:submit_answer)
          end
        end
      end

      context 'when no free attempts are available' do
        before { console.game.instance_variable_set(:@attempts, 1) }

        it 'puts marked result' do
          expect(console).to receive(:puts)
        end

        it 'puts error' do
          expect(console).to receive(:puts).and_raise
        end

        it '#finish_game call' do
          expect(console).to receive(:finish_game)
        end
      end
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
          allow(console).to receive_message_chain(:gets, :chomp).and_return(Console::YES)
          console.send(:input_selector)
        end

        after { console.send(:input_selector) }

        it 'return y/n alert' do
          expect(console).to receive(:print).with(" (y/n) #{message['alerts']['yes_or_no']}:")
        end
      end

      context 'allow user input' do
        before { allow(console).to receive(:print) }

        it 'y key should return true' do
          allow(console).to receive(:gets).and_return(Console::YES)
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
        allow(console).to receive(:prepare_storage_dir)
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

      it '#prepare_storage_dir call' do
        expect(console).to receive(:prepare_storage_dir)
      end

      it '#save_to_yml call' do
        expect(console).to receive(:save_to_yml)
      end
    end

    describe '#save_user_score' do
      context 'add score object when method was called' do
        specify { expect { console.send(:save_user_score) }.to change { console.scores.size }.from(0).to(1) }
      end
    end

    describe '#current_user_score' do
      specify { expect(console.send(:current_user_score)).to be_an_instance_of(Score) }
    end

    describe '#prepare_storage_dir' do
      let(:has_storage_dir) do
        console.send(:prepare_storage_dir)
        File.exists?(storage_dir)
      end

      context 'storage dir should be exists' do
        specify { expect(has_storage_dir).to be(true) }
      end
    end

    describe '#save_to_yml' do
      data_dir = File.expand_path('../../lib/codebreaker/data/.', File.dirname(__FILE__)).to_s
      after { File.delete(current_yml) }

      context 'calls methods' do
        before do
          allow(console).to receive(:scores)
          allow(console).to receive(:load_game_data)
          console.send(:save_to_yml)
        end

        after { console.send(:save_to_yml) }

        specify { expect(console).to receive(:scores) }
        specify { expect(console).to receive(:load_game_data) }
      end

      context 'when new scores exists' do
        it 'data folder should be not empty' do
          expect { console.send(:save_to_yml) }.to change { Dir.empty?(data_dir) }.from(true).to(false)
        end
      end
    end

    describe '#new_game' do
      before do
        allow(console).to receive(:print)
        allow(console).to receive(:input_selector).and_return(true)
        allow(console).to receive(:load_new_game)
        allow(console).to receive(:start_game)
        console.send(:new_game)
      end

      after { console.send(:new_game) }

      context 'new game dialog' do
        specify { expect(console).to receive(:print).with(message['alerts']['new_game']) }

        it '#input_selector call' do
          expect(console).to receive(:input_selector)
        end
      end

      context 'when user choose yes' do
        it '#load_new_game call' do
          expect(console).to receive(:load_new_game)
        end

        it '#start_game call' do
          expect(console).to receive(:start_game)
        end
      end

      context 'when user choose no' do
        before do
          allow(console).to receive(:input_selector).and_return(false)
          allow(console).to receive(:puts)
          allow(console).to receive(:exit_console)
        end

        it 'returns exit message' do
          expect(console).to receive(:puts).with(message['alerts']['shutdown'])
        end

        it '#exit_console call' do
          expect(console).to receive(:exit_console)
        end
      end
    end

    describe '#load_new_game' do
      before { console.send(:load_new_game) }

      specify { expect(console.game).to be_an_instance_of(Game) }

      it 'config of new game should be equal to config snapshot' do
        expect(console.game.configuration).to eq(console.instance_variable_get(:@game_config_snapshot))
      end
    end

    describe '#exit_console' do
      specify { expect { console.send(:exit_console) }.to raise_error(SystemExit) }
    end

    describe '#erase_scores' do
      before do
        allow(console).to receive(:print)
        allow(console).to receive(:input_selector)
        allow(console).to receive(:erase_game_data)
        allow(console).to receive(:exit_console)
        console.erase_scores
      end

      after { console.erase_scores }

      it 'returns warning message' do
        expect(console).to receive(:print).with(message['alerts']['erase_scores'])
      end

      it '#input_selector call' do
        expect(console).to receive(:input_selector)
      end

      it '#erase_game_data call' do
        allow(console).to receive(:input_selector).and_return(true)
        expect(console).to receive(:erase_game_data)
      end

      it '#exit_console call' do
        expect(console).to receive(:exit_console)
      end
    end

    describe '#erase_game_data' do
      context 'when scores empty' do
        before do
          allow(console).to receive(:puts)
          console.send(:erase_game_data)
        end

        after { console.send(:erase_game_data) }

        it 'returns error message' do
          expect(console).to receive(:puts).with(message['errors']['file_not_found'].red)
        end
      end

      context 'when scores not empty' do
        before { FileUtils.copy_file(test_yml, current_yml) }

        it 'returns info message' do
          expect { console.send(:erase_game_data) }.to output { message['info']['successfully_erased'].green }.to_stdout
        end
      end
    end
  end
end
