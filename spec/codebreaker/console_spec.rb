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
                  expect(console.scores.all? { |i| i.is_a?(Score) }).to be(true)
                end
              end
            end
          end
        end
      end
    end

    

  end
end
