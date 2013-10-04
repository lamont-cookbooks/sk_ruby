
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

include_recipe "sk_ruby::ubuntu"

package "curl"

chef_gem "fpm"

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

sk_ruby "2.0.0-p247" do
  rubygems "2.1.5"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/ruby"
  pkg_version "0.0.3"
end

sk_ruby_symlinks "/opt/ruby-2.0.0-p247/bin"
