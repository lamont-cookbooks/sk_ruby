
execute "pacman --sync -yy"

multipackage %w{ libxml2 libxslt wget zlib libyaml openssl readline }
