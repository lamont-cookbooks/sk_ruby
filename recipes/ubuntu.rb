
# remove old rubies
%w{ ruby ruby1.8-dev ruby1.9.1 ruby1.9.1-dev libruby1.9.1 libruby-extras libruby1.8-extras rubygems rubygems1.8 }.each do |pkg|
  package pkg do
    action :remove
  end
end

# install packages necessary to build
%w{ wget build-essential zlib1g-dev libreadline6-dev libssl-dev libyaml-dev }.each do |pkg|
  package pkg
end

case
when node['platform_version'].to_f >= 11.10
  package "libreadline6-dev"
else
  package "libreadline5-dev"
end

