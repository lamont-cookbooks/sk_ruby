
include_recipe "apt"

# remove old rubies
#pkgs_remove = %w{ ruby ruby1.9.1 ruby1.9.3 ruby1.9.1-dev libruby1.9.1 libruby-extras libruby1.8-extras }
#
#if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 14.04
#  pkgs_remove += %w{ ruby1.8-dev rubygems rubygems1.8 }
#end
#
#multipackage pkgs_remove do
#  action :remove
#end

# install packages necessary to build
multipackage %w{ wget zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev }

if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 11.10
  multipackage "libreadline5-dev"
else
  multipackage "libreadline6-dev"
end
