require 'spec_helper'

module Codebreaker
  RSpec.describe Message, :type => :helper do
    skip describe '#message' do
      specify do
        assign(:locale, Localization.new(:game))
        expect(helper.message).to be_an_instance_of(Hash)
      end
    end
  end
end
