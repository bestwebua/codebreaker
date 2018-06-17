require 'simplecov'
SimpleCov.start

rspec_custom = File.join(File.dirname(__FILE__), 'codebreaker/support/**/*.rb')
Dir[File.expand_path(rspec_custom)].each { |file| require file }

require 'codebreaker'

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

end
