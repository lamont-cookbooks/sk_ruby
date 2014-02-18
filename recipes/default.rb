
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

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
