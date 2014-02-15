require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

at_exit { ChefSpec::Coverage.report! }
