require 'rspec/expectations'

RSpec::Matchers.define :has_a_public_method do |expected|
  match do |actual|
    actual.public_methods.include?(expected)
  end
end
