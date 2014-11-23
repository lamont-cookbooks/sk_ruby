require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'
require 'matchers'

$: << File.expand_path(File.join(File.dirname( __FILE__ ), "../libraries"))

require 'sk_ruby_helpers'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

ChefSpec::Coverage.start!
