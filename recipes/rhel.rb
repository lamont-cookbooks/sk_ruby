
# remove old rubies
# %w{ ruby ruby1.8-dev ruby1.9.1 ruby1.9.3 ruby1.9.1-dev libruby1.9.1 libruby-extras libruby1.8-extras rubygems rubygems1.8 }.each do |pkg|
#   package pkg do
#     action :remove
#   end
# end

include_recipe "yum-epel" unless node['platform'] == 'fedora'

# install packages necessary to build
%w{ rpm-build wget openssl-devel libyaml-devel libxml2-devel libxslt-devel readline-devel }.each do |pkg|
  package pkg
end
