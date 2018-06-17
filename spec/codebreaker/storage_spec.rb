require 'spec_helper'

module Codebreaker
  RSpec.describe Storage do
    describe 'defined methods' do
      let(:class_with_module) do
        Class.new do
          include Storage
        end.new
      end
      specify { expect(class_with_module).to has_a_private_method(:load_game_data) }
      specify { expect(class_with_module).to has_a_private_method(:prepare_storage_dir) }
      specify { expect(class_with_module).to has_a_private_method(:save_to_yml) }
      specify { expect(class_with_module).to has_a_private_method(:erase_data_file) }
    end
  end
end
