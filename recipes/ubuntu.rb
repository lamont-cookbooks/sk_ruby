
include_recipe "apt"

# remove old rubies
%w{ ruby ruby1.8-dev ruby1.9.1 ruby1.9.3 ruby1.9.1-dev libruby1.9.1 libruby-extras libruby1.8-extras rubygems rubygems1.8 }.each do |pkg|
  package pkg do
    action :remove
  end
end

# install packages necessary to build
%w{ wget zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev }.each do |pkg|
  package pkg
end

if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 11.10
  package "libreadline5-dev"
else
  package "libreadline6-dev"
end
