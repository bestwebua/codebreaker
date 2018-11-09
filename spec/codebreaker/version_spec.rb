require 'spec_helper'

module Codebreaker
  RSpec.describe 'Codebreaker version' do
    specify { expect(VERSION).not_to be(nil) }
  end
end
