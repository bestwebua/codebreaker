require 'spec_helper'

module Codebreaker
  RSpec.describe Message do
    describe '#message' do
      let(:object) do
        Class.new do
          include Message
          define_method(:initialize) do
            @locale = Localization.new(:console)
          end
        end.new
      end

      specify do
        expect(object.send(:message)).to be_an_instance_of(Hash)
      end
    end
  end
end
