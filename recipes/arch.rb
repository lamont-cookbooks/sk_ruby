
execute "pacman --sync -yy"

%w{ wget zlib libxml2 libxslt libyaml openssl readline }.each do |pkg|
  package pkg
end
