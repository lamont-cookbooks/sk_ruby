
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

include_recipe "sk_ruby::ubuntu"

chef_gem "fpm"

sk_ruby "1.9.3-p327" do
  rubygems "1.8.24"
  gems [ "bundler", "rake", "fpm" ]
end

