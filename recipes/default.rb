
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

include_recipe "sk_ruby::ubuntu"

chef_gem "fpm"

my_gems = [
  "bundler",
  "rake",
  "fpm",
  "berkshelf",
]

sk_ruby "1.9.3-p327" do
  rubygems "1.8.24"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/ruby"
end

sk_ruby "1.9.3-p429" do
  rubygems "2.0.3"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/ruby"
end

sk_ruby "2.0.0-p195" do
  rubygems "2.0.3"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/ruby"
end

sk_ruby_symlinks "/opt/ruby-2.0.0-p195/bin"

