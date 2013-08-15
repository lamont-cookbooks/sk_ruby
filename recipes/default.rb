
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

include_recipe "sk_ruby::ubuntu"

package "curl"

chef_gem "fpm"

my_gems = [
  "bundler",
  "rake",
  "fpm",
  "berkshelf",
  "pry",
  "thor",
  "puma",
]

#sk_ruby "1.9.3-p327" do
#  rubygems "1.8.24"
#  gems my_gems
#  cache_uri_base "http://s3.scriptkiddie.org/ruby"
#  pkg_version "0.0.2"
#end
#
#sk_ruby "1.9.3-p429" do
#  rubygems "2.0.3"
#  gems my_gems
#  cache_uri_base "http://s3.scriptkiddie.org/ruby"
#  pkg_version "0.0.2"
#end

sk_ruby "2.0.0-p247" do
  rubygems "2.0.3"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/ruby"
  pkg_version "0.0.2"
end

sk_ruby_symlinks "/opt/ruby-2.0.0-p247/bin"

