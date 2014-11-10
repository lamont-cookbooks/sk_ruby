
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

# FIXME: port into opscode-cookbooks
package "zlib-devel compiletime install" do
  package_name case node['platform_family']
               when 'rhel', 'fedora', 'suse'
                 'zlib-devel'
               when 'arch'
                 'zlib'
               else
                 'zlib1g-dev'
               end
  action :nothing
end.run_action(:install)

case node['platform_family']
when 'debian'
  include_recipe "sk_ruby::ubuntu"
when 'rhel', 'fedora'
  include_recipe "sk_ruby::rhel"
when 'arch'
  include_recipe "sk_ruby::arch"
end

# needed for the LWRPs
chef_gem "fpm"
chef_gem "aws-sdk"
