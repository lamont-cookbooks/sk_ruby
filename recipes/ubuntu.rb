
include_recipe "apt"

# remove old rubies
pkgs_remove = %w{ ruby ruby1.9.1 ruby1.9.3 ruby1.9.1-dev libruby1.9.1 libruby-extras libruby1.8-extras }

if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 14.04
  pkgs_remove += %w{ ruby1.8-dev rubygems rubygems1.8 }
end

pkgs_remove.each do |pkg|
  package pkg do
    action :remove
    epic_fail true
  end
end

include_recipe "xml"

# install packages necessary to build
%w{ wget zlib1g-dev libssl-dev libyaml-dev }.each do |pkg|
  package pkg
end

if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 11.10
  package "libreadline5-dev"
else
  package "libreadline6-dev"
end
