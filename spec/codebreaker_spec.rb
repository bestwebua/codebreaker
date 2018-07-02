require 'spec_helper'

module Codebreaker
  RSpec.describe Codebreaker do
    specify { expect(subject).to be_const_defined(:VERSION) }
    specify { expect(subject).to be_const_defined(:Localization) }
    specify { expect(subject).to be_const_defined(:Message) }
    specify { expect(subject).to be_const_defined(:Motivation) }
    specify { expect(subject).to be_const_defined(:UserScore) }
    specify { expect(subject).to be_const_defined(:Storage) }
    specify { expect(subject).to be_const_defined(:GameConst) }
    specify { expect(subject).to be_const_defined(:Game) }
    specify { expect(subject).to be_const_defined(:GameConfiguration) }
    specify { expect(subject).to be_const_defined(:Score) }
    specify { expect(subject).to be_const_defined(:Console) }
  end
end
