require 'spec_helper'

module Codebreaker
  RSpec.describe Storage do
    before(:context) do
      current_yml = File.expand_path('../../lib/codebreaker/data/scores.yml', File.dirname(__FILE__)).to_s
      @env = RspecFileChef::FileChef.new(current_yml)
      @env.make
    end

    after(:context) do
      @env.clear
    end

    let(:instance_with_module) do
      Class.new do
        include Storage
      end.new
    end

    describe 'defined methods' do
      specify { expect(instance_with_module).to has_a_public_method(:storage_path) }
      specify { expect(instance_with_module).to has_a_private_method(:apply_external_path) }
      specify { expect(instance_with_module).to has_a_private_method(:load_game_data) }
      specify { expect(instance_with_module).to has_a_private_method(:prepare_storage_dir) }
      specify { expect(instance_with_module).to has_a_private_method(:save_to_yml) }
      specify { expect(instance_with_module).to has_a_private_method(:erase_data_file) }
    end

    describe '#apply_external_path' do
      let(:storage_path) { instance_with_module.storage_path }

      context 'without argument' do
        before { instance_with_module.send(:apply_external_path) }
        let(:local_storage_path) { @env.tracking_files.first }

        it 'returns path to local yml-file' do
          expect(storage_path).to eq(local_storage_path)
        end
      end

      context 'with argument' do
        context 'wrong argument' do
          let(:with_nonexistent_path) do
            instance_with_module.send(:apply_external_path, 'nonexistent_path')
          end

          specify do
            expect { with_nonexistent_path }.to raise_error(ArgumentError, 'Invalid external path.')
          end
        end

        context 'right argument' do
          let(:external_storage_path) { @env.test_dir }
          let(:full_external_yml_path) { @env.test_files.first }

          before { instance_with_module.send(:apply_external_path, external_storage_path) }

          it 'returns path to external yml-file' do
            expect(storage_path).to eq(full_external_yml_path)
          end
        end
      end
    end
  end
end
