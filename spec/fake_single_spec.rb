require 'spec_helper'

describe "fake::single" do
  context "the sk_ruby provider" do
    let(:pkg_path) { "/var/chef/cache/ruby-2.1.0-0.0.1_ubuntu_13_04_amd64.deb" }

    let(:test_fake_single) do
      ChefSpec::Runner.new(
        step_into: 'sk_ruby',
        platform: 'ubuntu',
        version: "13.04",
      ).converge(described_recipe)
    end

    it "installs ruby 2.1.0" do
      expect(test_fake_single).to download_sk_ruby("2.1.0")
      expect(test_fake_single).to install_sk_ruby("2.1.0")
    end

    context "when remote_file 404 leaves a zero-length turd (Chef Bug)" do
      before do
        File.should_receive(:zero?).with(pkg_path).and_return(true)
      end
      it "cleans it up" do
        expect(test_fake_single).to delete_file(pkg_path)
      end
    end

    context "when remote_file does not leave a zero-length turd" do
      before do
        File.should_receive(:zero?).with(pkg_path).and_return(false)
      end
      it "should not clean it up" do
        expect(test_fake_single).not_to delete_file(pkg_path)
      end
    end

    it "does things" do
      expect(test_fake_single).to create_remote_file("/var/chef/cache/ruby-2.1.0-0.0.1_ubuntu_13_04_amd64.deb")
      expect(test_fake_single).to run_bash("compile ruby 2.1.0 from sources")
      expect(test_fake_single).to run_bash("install rubygems 2.2.1 into 2.1.0")
      expect(test_fake_single).to run_bash("install gem bundler into 2.1.0")
      expect(test_fake_single).to run_bash("install gem rake into 2.1.0")
      expect(test_fake_single).to run_bash("install gem pry into 2.1.0")
      expect(test_fake_single).to run_bash("package ruby 2.1.0 with fpm")
      expect(test_fake_single).to install_dpkg_package("/var/chef/cache/ruby-2.1.0-0.0.1_ubuntu_13_04_amd64.deb")
    end

  end

  context "the sk_ruby_symlinks provider" do
    let(:test_fake_single) do
      ChefSpec::Runner.new(
        step_into: 'sk_ruby_symlinks',
        platform: 'ubuntu',
        version: "13.04",
      ).converge(described_recipe)
    end

    let(:bin_path) { "/opt/ruby-2.1.0/bin" }

    let(:binaries) { %w{pry rake} }

    before do
      Dir.stub(:[]).and_call_original  # conflict with rspec?
      Dir.should_receive(:[]).with( ::File.join(bin_path, "*") ).and_return( binaries.map { |x| "#{bin_path}/#{x}" } )
    end

    it "links ruby 2.1.0 into /usr/local/bin" do
      expect(test_fake_single).to install_sk_ruby_symlinks(bin_path)
    end

  end
end
