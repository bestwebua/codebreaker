require 'spec_helper'

module Codebreaker
  RSpec.describe UserScore do
    let(:instance_with_module) do
      Class.new do
        include UserScore
      end.new
    end

    describe 'defined methods' do
      specify { expect(instance_with_module).to has_a_private_method(:current_user_score) }
      specify { expect(instance_with_module).to has_a_private_method(:save_user_score) }
    end
  end
end
