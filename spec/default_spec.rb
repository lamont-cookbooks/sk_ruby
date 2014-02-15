require 'spec_helper'

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '13.04'
  describe 'sk_ruby::default' do

    let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

    it 'includes the build-essential recipe' do
      expect(chef_run).to include_recipe('build-essential')
    end

  end
end
