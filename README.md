# sk_ruby Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/sk_ruby.svg)](https://community.opscode.com/cookbooks/sk_ruby)
[![Build Status](https://secure.travis-ci.org/lamont-granquist/sk_ruby.png?branch=master)](http://travis-ci.org/lamont-granquist/sk_ruby)

## Audience (AKA Why Another Ruby Cookbook?)

- Rebuilding ruby from source on every install is stupid (build once then install binaries)
- Most ruby versions managers have too much magic sauce
- I just want to install an RPM/deb into /opt
- I might want some symlinks in /usr/local/bin to the latest version

## Description

LWRP for source builds of ruby binaries.  Since source building on every chef-client run sucks, I added the ability to download a
cached pre-build package from S3 so that you only have to download it once.  Since uploading the package to S3 was fussy and manual
I automated that problem away so that the first time one of your servers builds the new package it uploads it to S3 so that the other
servers can download it.

This does not use rbenv/rvm/chruby.  It just builds a package and install it into /opt.  There is a helper RPM to wire up all the
binaries into /usr/bin if you want the package to replace the system ruby packages (otherwise you probably want to either be
specific with the full path to ruby in your shebangs, or else you want to get the /opt installed ruby into the PATH where it 
needs to be used).

## Supports

Tested:

* Ubuntu 10.04-13.10
* RHEL/CentOS/Oracle/Scientific 5.x/6.x
* Debian 7.0
* Fedora 19

Probably Works:

* LinuxMint
* Amazon 2012.09 (and probably others)
* Debian 6.0
* Fedora 18-20?

## Supported Ruby Builds:

Tested:

* Ruby 1.8.7-p374
* Ruby 1.9.3-p484
* Ruby 2.0.0-p353
* Ruby 2.1.0

Other versions should work, nothing before 1.8.7 will be supported.

## Requirements

* Omnibus Chef >= 11.6.0

## Cookbook Dependencies

* build-essential
* apt
* sk_s3_file

## Resources/Providers

### sk_ruby

This resource source compiles ruby and uses s3 as a cache for the deb/rpm artifact that it produces.

#### Example

This will compile ruby-2.1.0 with rubygems 2.2.1 and the listed gems pre-installed.  It will use the "mybucket" s3 bucket to
store and retrieve the compiled rubygems package.  The resultant package will install in /opt/ruby-2.1.0/bin/ruby.  I've pulled
the AWS creds out of an encrypted data bag as an example of best practices, you don't have to use one.

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
* `pkg_file` - Name of the package to build/install (defaults to `ruby-<version>-<pkg_version>_<platform>_<platform_version>_<arch>.deb`)

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

## Similar Cookbook

- https://github.com/danielsdeleo/omnibus-rubies
- https://github.com/fnichol/chef-ruby_build

## Bugs

- There's an intentional `ignore_failure true` which throws a stack trace with a 404 on the first run when you haven't yet uploaded
a pacakge to S3 yet.  The stack trace is not a bug.  Needs fixing in Chef.

- Right after the 404 the `remote_file` resource leaves a zero-length turd which we are forced to clean up.  Needs fixing in Chef.

## Contributing

Just open a PR or Issue on GitHub.

DO NOT Submit PRs for Ruby 1.8.7 support.
DO NOT Submit PRs for Chef < 11.6.0 support.

If you want either of those, make a fork and maintain it yourself.

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
