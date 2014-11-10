require 'spec_helper'
require 'aws-sdk'

require 'sk_ruby_helpers'

describe "fake::download" do
  let(:pkg_path) { "/var/chef/cache/#{pkg_name}" }
  context "on ubuntu 13.04" do
    before do
      allow(::File).to receive(:zero?).with(pkg_path).and_return(false)
    end

    let(:pkg_name) { "ruby-2.1.0-0.0.1_ubuntu_13_04_amd64.deb" }

    let(:runner) do
      ChefSpec::Runner.new(
        step_into: 'sk_ruby',
        platform: 'ubuntu',
        version: "13.04",
      )
    end

    let(:test) { runner.converge(described_recipe) }

    it "downloads ruby 2.1.0" do
      expect(test).to download_sk_ruby("2.1.0")
    end

    it "should not call delete on the pkg_path if there's no zero length file" do
      expect(test).not_to delete_file(pkg_path)
    end

    it "should call sk_s3_file since we gave it credentials" do
      expect(test).to create_sk_s3_file(pkg_path)
    end

    context "when Chef leaves a zero-length turd on 404" do
      before do
        allow(::File).to receive(:zero?).with(pkg_path).and_return(true)
      end

      it "should call delete on the pkg_path if there's no zero length file" do
        expect(test).to delete_file(pkg_path)
      end
    end

    %w{aws_access_key_id aws_secret_access_key aws_bucket aws_path}.each do |attr|
      context "When missing #{attr}" do
        let(:test) do
          runner.converge(described_recipe) do
            runner.find_resource(:sk_ruby, "2.1.0").instance_variable_set("@#{attr}", nil)
          end
        end

        it "should raise an exception" do
          expect{ test }.to raise_error
        end

        context "but with cache_uri_base set" do
          let(:test) do
            runner.converge(described_recipe) do
              runner.find_resource(:sk_ruby, "2.1.0").instance_variable_set("@#{attr}", nil)
              runner.find_resource(:sk_ruby, "2.1.0").instance_variable_set("@cache_uri_base", "http://s3.scriptkiddie.org/nonexist")
            end
          end

          it "should not raise an exception" do
            expect{ test }.not_to raise_error
          end

          it "should call remote_file to download the file" do
            expect(test).to create_remote_file(pkg_path)
          end
        end
      end
    end
  end
end

describe "fake::compile" do
end

describe "fake::install" do
end

describe "fake::upload" do
end

#describe "fake::single" do
#  context "the sk_ruby provider" do
#
#    let(:access_hash) { {:access_key_id=>"AKIAIISJV5TZ3FPWU3TA", :secret_access_key=>"ABCDEFGHIJKLMNOP1234556/s"} }
#    let(:aws_bucket) { "mybucket" }
#    let(:aws_path) { "/something/#{pkg_name}" }
#    let(:pkg_path) { "/var/chef/cache/#{pkg_name}" }
#
#    def stub_s3
#      s3_double = double(AWS::S3)
#      allow(AWS::S3).to receive(:new).with(access_hash).and_return(s3_double)
#      s3_client_double = double(AWS::S3::Client)
#      allow(s3_double).to receive(:client)
#      s3_buckets = double(AWS::S3::BucketCollection)
#      s3_bucket = double(AWS::S3::Bucket)
#      allow(s3_double).to receive(:buckets).and_return(s3_buckets)
#      allow(s3_buckets).to receive(:[]).with(aws_bucket).and_return(s3_bucket)
#      s3_objects = double(AWS::S3::ObjectCollection)
#      s3_object = double(AWS::S3::Object)
#      allow(s3_bucket).to receive(:objects).and_return(s3_objects)
#      allow(s3_objects).to receive(:[]).with(aws_path).and_return(s3_object)
#      allow(s3_object).to receive(:exists?).and_return(true)
#    end
#
#    before do
#      allow(::File).to receive(:exist?).and_call_original
#      allow(::SKRubyHelpers).to receive(:do_compile?).and_return(true)
#      allow(::File).to receive(:exist?).with(pkg_path).and_return(true)
#      allow(::File).to receive(:zero?).with(pkg_path).and_return(false)
#      stub_s3
#    end
#
#    context "on ubuntu 13.04" do
#      let(:pkg_name) { "ruby-2.1.0-0.0.1_ubuntu_13_04_amd64.deb" }
#
#      let(:test_fake_single) do
#        ChefSpec::Runner.new(
#          step_into: 'sk_ruby',
#          platform: 'ubuntu',
#          version: "13.04",
#        ).converge(described_recipe)
#      end
#
#      it "installs ruby 2.1.0" do
#        expect(test_fake_single).to download_sk_ruby("2.1.0")
#        expect(test_fake_single).to compile_sk_ruby("2.1.0")
#        expect(test_fake_single).to upload_sk_ruby("2.1.0")
#        expect(test_fake_single).to install_sk_ruby("2.1.0")
#      end
#
#      context "when remote_file 404 leaves a zero-length turd (Chef Bug)" do
#        before do
#          File.should_receive(:zero?).with(pkg_path).and_return(true)
#        end
#        it "cleans it up" do
#          expect(test_fake_single).to delete_file(pkg_path)
#        end
#      end
#
#      context "when remote_file does not leave a zero-length turd" do
#        before do
#          File.should_receive(:zero?).with(pkg_path).and_return(false)
#        end
#        it "should not clean it up" do
#          expect(test_fake_single).not_to delete_file(pkg_path)
#        end
#      end
#
#      it "does things" do
#        expect(test_fake_single).to create_sk_s3_file(pkg_path)
#        expect(test_fake_single).to run_bash("compile ruby 2.1.0 from sources")
#        expect(test_fake_single).to run_bash("install rubygems 2.2.1 into 2.1.0")
#        expect(test_fake_single).to run_bash("install gem bundler into 2.1.0")
#        expect(test_fake_single).to run_bash("install gem rake into 2.1.0")
#        expect(test_fake_single).to run_bash("install gem pry into 2.1.0")
#        expect(test_fake_single).to run_bash("package ruby 2.1.0 with fpm")
#        expect(test_fake_single).to install_dpkg_package(pkg_path)
#      end
#
#    end
#
#    context "on centos 6.5" do
#
#      let(:pkg_name) { "ruby-2.1.0-0.0.1_el_6_amd64.rpm" }
#
#      let(:test_fake_single) do
#        ChefSpec::Runner.new(
#          step_into: 'sk_ruby',
#          platform: "centos",
#          version: "6.5",
#        ).converge(described_recipe)
#      end
#
#      it "installs ruby 2.1.0" do
#        expect(test_fake_single).to download_sk_ruby("2.1.0")
#        expect(test_fake_single).to compile_sk_ruby("2.1.0")
#        expect(test_fake_single).to upload_sk_ruby("2.1.0")
#        expect(test_fake_single).to install_sk_ruby("2.1.0")
#      end
#
#      context "when remote_file 404 leaves a zero-length turd (Chef Bug)" do
#        before do
#          File.should_receive(:zero?).with(pkg_path).and_return(true)
#        end
#        it "cleans it up" do
#          expect(test_fake_single).to delete_file(pkg_path)
#        end
#      end
#
#      context "when remote_file does not leave a zero-length turd" do
#        before do
#          File.should_receive(:zero?).with(pkg_path).and_return(false)
#        end
#        it "should not clean it up" do
#          expect(test_fake_single).not_to delete_file(pkg_path)
#        end
#      end
#
#      it "does things" do
#        expect(test_fake_single).to create_sk_s3_file(pkg_path)
#        expect(test_fake_single).to run_bash("compile ruby 2.1.0 from sources")
#        expect(test_fake_single).to run_bash("install rubygems 2.2.1 into 2.1.0")
#        expect(test_fake_single).to run_bash("install gem bundler into 2.1.0")
#        expect(test_fake_single).to run_bash("install gem rake into 2.1.0")
#        expect(test_fake_single).to run_bash("install gem pry into 2.1.0")
#        expect(test_fake_single).to run_bash("package ruby 2.1.0 with fpm")
#        expect(test_fake_single).to install_rpm_package(pkg_path)
#      end
#
#    end
#
#  end
#
#  context "the sk_ruby_symlinks provider" do
#    let(:test_fake_single) do
#      ChefSpec::Runner.new(
#        step_into: 'sk_ruby_symlinks',
#        platform: 'ubuntu',
#        version: "13.04",
#      ).converge(described_recipe)
#    end
#
#    let(:bin_path) { "/opt/ruby-2.1.0/bin" }
#
#    let(:binaries) { %w{pry rake} }
#
#    before do
#      Dir.stub(:[]).and_call_original  # conflict with rspec?
#      Dir.should_receive(:[]).with( ::File.join(bin_path, "*") ).and_return( binaries.map { |x| "#{bin_path}/#{x}" } )
#    end
#
#    it "links ruby 2.1.0 into /usr/local/bin" do
#      expect(test_fake_single).to install_sk_ruby_symlinks(bin_path)
#    end
#
#  end
#end
