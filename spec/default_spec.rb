require 'spec_helper'

describe "sk_ruby::default" do

  shared_examples_for "common configuration for all platforms" do
    it 'includes the build-essential recipe' do
      expect(chef_run).to include_recipe('build-essential')
    end

    it 'installs the fpm gem' do
      expect(chef_run).to install_chef_gem('fpm')
    end

    it 'installs the aws-sdk gem' do
      expect(chef_run).to install_chef_gem('aws-sdk')
    end
  end

  shared_examples_for "debian-like O/S" do
    it_behaves_like "common configuration for all platforms"

    it 'includes the sk_ruby::ubuntu recipe' do
      expect(chef_run).to include_recipe('sk_ruby::ubuntu')
    end

    it 'includes the apt recipe' do
      expect(chef_run).to include_recipe('apt')
    end

    %w{ ruby ruby1.8-dev ruby1.9.1 ruby1.9.3 ruby1.9.1-dev libruby1.9.1 libruby-extras libruby1.8-extras rubygems rubygems1.8 }.each do |pkg|
      it "removes package #{pkg}" do
        expect(chef_run).to remove_package(pkg)
      end
    end

    %w{ wget zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev }.each do |pkg|
      it "installs package #{pkg}" do
        expect(chef_run).to install_package(pkg)
      end
    end
  end

  %w{12.04 13.04}.each do |version|
    context "on ubuntu #{version}" do
      let(:chef_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: version).converge(described_recipe) }

      it_behaves_like "debian-like O/S"

      it "installs libreadline6-dev" do
        expect(chef_run).to install_package("libreadline6-dev")
      end
    end
  end

  %w{10.04}.each do |version|
    context "on ubuntu #{version}" do
      let(:chef_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: version).converge(described_recipe) }

      it_behaves_like "debian-like O/S"

      it "installs libreadline6-dev" do
        expect(chef_run).to install_package("libreadline5-dev")
      end
    end
  end

  %w{6.0.5 7.0 7.4}.each do |version|
    context "on debian #{version}" do
      let(:chef_run) { ChefSpec::Runner.new(platform: 'debian', version: version).converge(described_recipe) }

      it_behaves_like "debian-like O/S"
    end
  end

  shared_examples_for "RHEL-like O/S" do

    it_behaves_like "common configuration for all platforms"

    it "includes the sk_ruby::rhel recipe" do
      expect(chef_run).to include_recipe('sk_ruby::rhel')
    end

    it "includes the yum-epel recipe" do
      expect(chef_run).to include_recipe('yum-epel')
    end

    %w{ wget zlib-devel openssl-devel libyaml-devel libxml2-devel libxslt-devel readline-devel }.each do |pkg|
      it "installs package #{pkg}" do
        expect(chef_run).to install_package(pkg)
      end
    end
  end

  RHEL_VERSIONS = {
    "redhat" => %w{5.6 5.10 6.0 6.5},
    "amazon" => %w{2012.09},
    "centos" => %w{5.8 5.9 6.0 6.5},
    "fedora" => %w{18},
  }

  RHEL_VERSIONS.each_key do |platform|
    RHEL_VERSIONS[platform].each do |version|
      context "on #{platform} #{version}" do
        let(:chef_run) { ChefSpec::Runner.new(platform: platform, version: version).converge(described_recipe) }

        it_behaves_like "RHEL-like O/S"
      end
    end
  end

  # TODO:
  # FreeBSD
  # Gentoo
  # MACOSX
  # OmniOS
  # OpenBSD
  # OpenSuSE
  # SmartOS
  # SuSE
  # Windows

end
