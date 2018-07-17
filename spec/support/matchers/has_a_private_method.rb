require 'rspec/expectations'

RSpec::Matchers.define :has_a_private_method do |expected|
  match do |actual|
    actual.private_methods.include?(expected)
  end
end
