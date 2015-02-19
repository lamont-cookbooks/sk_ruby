maintainer       "Lamont Granquist"
maintainer_email "lamont@scriptkiddie.org"
license          "Apache 2.0"
description      "LWRPs for installing source-built rubies.  Automatically uploads built s3 binaries.  Subsequent runs will download instead of rebuilding."
long_description "LWRPs for installing source-built rubies.  Automatically uploads built s3 binaries.  Subsequent runs will download instead of rebuilding."
version          "2.0.18"
name             "sk_ruby"

depends "build-essential", '>= 2.0.0'
depends "apt"
depends "sk_s3_file"
depends "yum-epel"
depends "multipackage"
