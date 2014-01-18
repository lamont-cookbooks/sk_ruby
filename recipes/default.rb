
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

include_recipe "sk_ruby::ubuntu"

package "curl"

chef_gem "fpm"
chef_gem "aws-sdk"

my_gems = %w{
  bundler
  rake
  fpm
  pry
  pry-byebug
  pry-remote
  pry-rescue
  pry-stack_explorer
  thor
  puma
  unicorn
  thin
  webrick
}

creds = Chef::EncryptedDataBagItem.load("encrypted", "creds")

sk_ruby "2.1.0" do
  rubygems "2.2.1"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/ruby"
  pkg_version "0.0.1"
  aws_access_key_id creds["ec2_access_key"]
  aws_secret_access_key creds["ec2_secret_key"]
  aws_bucket "s3.scriptkiddie.org"
  aws_path "ruby"
end

sk_ruby_symlinks "/opt/ruby-2.1.0/bin"

attribute :aws_access_key_id, :kind_of => String
attribute :aws_secret_access_key, :kind_of => String
attribute :aws_bucket, :kind_of => String
attribute :aws_path, :kind_of => String
