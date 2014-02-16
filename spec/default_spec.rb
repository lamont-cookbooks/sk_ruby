require 'spec_helper'

describe "sk_ruby::default" do

  shared_examples_for "common configuration for all platforms" do
    it 'includes the build-essential recipe' do
      expect(chef_run).to include_recipe('build-essential')
    end

    it 'installs the fpm gem' do
      expect(chef_run).to install_chef_gem('fpm')
    end

    it 'installs the fpm gem' do
      expect(chef_run).to install_chef_gem('aws-sdk')
    end
  end

  %w{10.04 12.04 13.04}.each do |version|
    context "on ubuntu #{version}" do

      let(:chef_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: version).converge(described_recipe) }

      it_behaves_like "common configuration for all platforms"

      it 'includes the sk_ruby::ubuntu recipe' do
        expect(chef_run).to include_recipe('sk_ruby::ubuntu')
      end
    end
  end

  shared_examples_for "RHEL-like O/S" do

    it_behaves_like "common configuration for all platforms"

    it "includes the sk_ruby::rhel recipe" do
      expect(chef_run).to include_recipe('sk_ruby::rhel')
    end
  end

  %w{5.6 5.10 6.0 6.5}.each do |version|
    context "on redhat #{version}" do
      let(:chef_run) { ChefSpec::Runner.new(platform: 'redhat', version: version).converge(described_recipe) }

      it_behaves_like "RHEL-like O/S"
    end
  end

  %w{2012.09}.each do |version|
    context "on amazon #{version}" do
      let(:chef_run) { ChefSpec::Runner.new(platform: 'amazon', version: version).converge(described_recipe) }

      it_behaves_like "RHEL-like O/S"
    end
  end
end
