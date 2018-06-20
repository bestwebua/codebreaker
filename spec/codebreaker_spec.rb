require_relative '../lib/codebreaker'

module Codebreaker
  RSpec.describe Codebreaker do
    specify { should be_const_defined(:VERSION) }
    specify { should be_const_defined(:Localization) }
    specify { should be_const_defined(:Message) }
    specify { should be_const_defined(:Motivation) }
    specify { should be_const_defined(:Storage) }
    specify { should be_const_defined(:Game) }
    specify { should be_const_defined(:GameConfiguration) }
    specify { should be_const_defined(:Score) }
    specify { should be_const_defined(:Console) }
  end
end
