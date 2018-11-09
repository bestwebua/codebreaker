require 'spec_helper'

module Codebreaker
  RSpec.describe Motivation do
    let(:instance_with_module) do
      Class.new do
        include Motivation
      end.new
    end

    describe 'defined methods' do
      specify { expect(instance_with_module).to has_a_private_method(:message_is_allowed?) }
      specify { expect(instance_with_module).to has_a_private_method(:motivation_message) }
    end

    describe 'method call' do
      context 'without argument' do
        specify do
          expect { instance_with_module.send(:motivation_message) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
