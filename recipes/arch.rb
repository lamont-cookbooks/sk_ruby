
execute "pacman --sync -yy"

include_recipe "xml"

%w{ wget zlib libyaml openssl readline }.each do |pkg|
  package pkg
end
