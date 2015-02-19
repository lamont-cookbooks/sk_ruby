
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

zlib_package = case node['platform_family']
               when 'rhel', 'fedora', 'suse'
                 'zlib-devel'
               when 'arch'
                 'zlib'
               else
                 'zlib1g-dev'
               end

if Gem::Requirement.new("<= 12.1.0").satisfied_by?(Gem::Version.new(Chef::VERSION))
  package "zlib-devel compiletime install" do
    package_name zlib_package
    action :nothing
  end.run_action(:install)
else
  multipackage zlib_paackage
end

case node['platform_family']
when 'debian'
  include_recipe "sk_ruby::ubuntu"
when 'rhel', 'fedora'
  include_recipe "sk_ruby::rhel"
when 'arch'
  include_recipe "sk_ruby::arch"
end

# needed for the LWRPs
chef_gem "fpm" do
  compile_time false if respond_to?(:compile_time)
end

chef_gem "aws-sdk" do
  version "~> 1.0"
  compile_time false
end
