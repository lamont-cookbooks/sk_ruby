[![Build Status](https://secure.travis-ci.org/lamont-granquist/sk_ruby.png?branch=master)](http://travis-ci.org/lamont-granquist/sk_ruby)

## Description

LWRP to build and install ruby binaries from source into /opt.  Uses fpm to package into RPMs or deb files.  Will download a prebuilt
cached package from a URL instead of source-compiling.  If given s3 credentials, after source compiling it will upload the pacakge to
s3 to avoid the build step for other servers (and to completely automate the compile-package-upload-to-s3 process).

## Requirements

* Ubuntu 13.04
* Ruby >= 1.9

## Cookbook Dependencies

* build-essential
* apt

## Resources/Providers

### sk_ruby

This resource source compiles ruby and uses s3 as a cache for the deb/rpm artifact that it produces.

#### Example

This will compile ruby-2.1.0 with rubygems 2.2.1 and the listed gems pre-installed.  It will use the "mybucket" s3 bucket to
store and retrieve the compiled rubygems package.  The resultant package will install in /opt/ruby-2.1.0/bin/ruby.

``` ruby
my_gems = %w{ bundler rake fpm pry thor puma unicorn thin webrick }

creds = Chef::EncryptedDataBagItem.load("encrypted", "creds")

sk_ruby "2.1.0" do
  rubygems "2.2.1"
  gems my_gems
  cache_uri_base "http://mybucket.s3.amazonaws.com/ruby"
  pkg_version "0.0.1"
  aws_access_key_id creds["ec2_access_key"]
  aws_secret_access_key creds["ec2_secret_key"]
  aws_bucket "mybucket"
  aws_path "ruby"
end
```

#### Actions

- `:install` - install the ruby package, build and upload if required

#### Parameters

* `version` - Ruby version, must be of the form "1.9.3-p484" or "2.1.0" (NAME ATTRIBUTE)
* `rubygems` - Version of rubygems to install
* `pkg_version` - Iteration of the package (previous iterations will be upgraded)
* `gems` - Additional gems to install
* `cache_uri_base` - The base of the URI to find the cached package at
* `install_path` - Path to install the ruby to (defaults to `/opt/ruby-<version>`)
* `ruby_url` - URI to download ruby from (defaults to correct ftp.ruby-lang.org URI)
* `deb_file` - Name of the package to build/install (defaults to `ruby-<version>-<pkg_version>_<platform>_<platform_version>_<arch>.deb`)

Excluding any of these will avoid publishing to s3, but compile+install will still work:

* `aws_access_key_id` - Access key for uploading to s3
* `aws_secret_key_id` - Secret key for uploading to s3
* `aws_bucket` - Bucket for uploading to s3
* `aws_path` - Path inside the bucket for uploading to s3

### sk_ruby_symlinks

This is a mini-alternatives system.  It will look in the directory you specify and symlink all the binaries into /usr/bin.
By default it skips chef binaries to not conflict with omnibus-installed chef.  You probably only want to use one of these
resources.

#### Example

This will setup symlinks in /usr/bin for the ruby-2.1.0 installed by the previous `sk_ruby` resource.

``` ruby
sk_ruby_symlinks "/opt/ruby-2.1.0/bin"
```

#### Actions

- `:install` - Setup the symlinks

#### Parameters

* `bin_path` - Path to the ruby binary directory (NAME ATTRIBUTE)
* `exclude` - List of binaries not to link into /usr/bin (defaults to chef-client, knife, chef-solo, chef-shell, chef-apply, ohai, shef)

## Recipes

* `default` - Installs build depdendencies for building ruby based on the platform of the host (OPTIONAL)

## Attributes

None

## Usage

Put 'depends sk_ruby' in your metadata.rb to gain access to the LWRPs in your code.

## License and Author

- Author:: Lamont Granquist (<lamont@scriptkiddie.org>)

```text
Copyright:: 2014 Lamont Granquist

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

