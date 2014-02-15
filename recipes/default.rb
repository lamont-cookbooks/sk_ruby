
#
# prep recipe to setup prequisites for the LWRP
#

include_recipe "build-essential"

case node['platform_family']
when 'debian'
  include_recipe "sk_ruby::ubuntu"
when 'rhel'
  include_recipe "sk_ruby::rhel"
end

# needed for the LWRPs
chef_gem "fpm"
chef_gem "aws-sdk"
