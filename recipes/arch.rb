
execute "pacman --sync -yy"

multipackage_install %w{ libxml2 libxslt wget zlib libyaml openssl readline }
