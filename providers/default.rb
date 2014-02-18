
# absolutely will not fix this for Chef 10, do not ask
use_inline_resources

def gen_platform_string
  # generate a string indicating which platform version we are on
  platform = node[:platform]
  platform_version = node[:platform_version]
  # all the EL clones can share pre-build binaries
  if %w{redhat centos oracle scientific}.include?(platform)
    platform = "el"
    platform_version = platform_version.match(/^(\d+)/)[1]
  end
  # FIXME: amazon and fedora could probably share el binaries

  arch = node[:kernel][:machine] == "x86_64" ? "amd64" : "i386"

  "#{platform}_#{platform_version}_#{arch}".gsub(/\./, "_")
end

def gen_pkg_file(new_resource)
  ruby_version = new_resource.version
  pkg_version = new_resource.pkg_version || "0.0.1"

  platform_string = gen_platform_string
  pkg_file = new_resource.pkg_file || "ruby-#{ruby_version}-#{pkg_version}_#{platform_string}"
  case node['platform_family']
  when 'debian'
    pkg_file << ".deb"
  when 'rhel', 'fedora'
    pkg_file << ".rpm"
  end
  pkg_file
end

def gen_pkg_path(pkg_file)
  "#{Chef::Config[:file_cache_path]}/#{pkg_file}"
end

action :download do
  cache_uri_base = new_resource.cache_uri_base

  aws_access_key_id = new_resource.aws_access_key_id
  aws_secret_access_key = new_resource.aws_secret_access_key
  aws_bucket = new_resource.aws_bucket
  aws_path = new_resource.aws_path

  pkg_file = gen_pkg_file(new_resource)
  pkg_path = gen_pkg_path(pkg_file)

  if aws_access_key_id && aws_secret_access_key && aws_bucket && aws_path
    sk_s3_file pkg_path do
      remote_path "#{aws_path}/#{pkg_file}"
      bucket aws_bucket
      aws_access_key_id aws_access_key_id
      aws_secret_access_key aws_secret_access_key
      owner "root"
      group "root"
      mode "0644"
      action :create
      ignore_failure true  # 404s are expected on a first run
    end
  elsif cache_uri_base
    cache_uri = "#{cache_uri_base}/#{pkg_file}"
    Chef::Log.debug("sk_ruby cache_uri: #{cache_uri}")
    remote_file pkg_path do
      source cache_uri
      owner "root"
      group "root"
      mode "0644"
      action :create
      ignore_failure true  # 404s are expected on a first run
    end
  else
    raise "must provide cache_uri_base or all aws credentials and location information"
  end

  # clean up zero-length turds from 404s due to chef bug
  file pkg_path do
    action :delete
    only_if { ::File.zero?(pkg_path) }
  end
end

action :install do
  ruby_version = new_resource.version
  # minor version for "2.0.0-p195" => "2.0"
  ruby_minor_version = new_resource.version[/^(\d+\.\d+)/, 1]
  rubygems_version = new_resource.rubygems
  pkg_version = new_resource.pkg_version || "0.0.1"
  gems = new_resource.gems

  aws_access_key_id = new_resource.aws_access_key_id
  aws_secret_access_key = new_resource.aws_secret_access_key
  aws_bucket = new_resource.aws_bucket
  aws_path = new_resource.aws_path

  install_path = new_resource.install_path || "/opt/ruby-#{ruby_version}"
  url = new_resource.ruby_url || "ftp://ftp.ruby-lang.org//pub/ruby/#{ruby_minor_version}/ruby-#{ruby_version}.tar.gz"

  pkg_file = gen_pkg_file(new_resource)
  pkg_path = gen_pkg_path(pkg_file)

  jobs = 3
  jobs = node['cpu']['total'] + 1 if node['cpu'] && node['cpu']['total']

  bash "compile ruby #{ruby_version} from sources" do
    cwd "/tmp"
    code <<-EOF
      rm -rf /tmp/ruby-#{ruby_version}
      rm -f /tmp/ruby-#{ruby_version}.tar.gz
      wget #{url}
      tar xzf ruby-#{ruby_version}.tar.gz && cd ruby-#{ruby_version}
      ./configure --prefix=#{install_path} --disable-install-doc >/dev/null
      make -j #{jobs} >/dev/null
      rm -rf #{install_path}
      make install
    EOF
    not_if { ::File.exists?(pkg_path) }
  end

  if rubygems_version
    bash "install rubygems #{rubygems_version} into #{ruby_version}" do
      cwd "/tmp"
      code <<-EOF
        rm -rf /tmp/rubygems-#{rubygems_version}
        rm -f /tmp/rubygems-#{rubygems_version}.tgz
        wget http://production.cf.rubygems.org/rubygems/rubygems-#{rubygems_version}.tgz
        tar -xzf rubygems-#{rubygems_version}.tgz && cd rubygems-#{rubygems_version}
        #{install_path}/bin/ruby setup.rb --no-format-executable >/dev/null
      EOF
      environment 'LC_ALL' => 'en_US.utf-8' # rubygems 2.0.3 hack
      not_if { ::File.exists?(pkg_path) }
    end

    gems.each do |gem|
      bash "install gem #{gem} into #{ruby_version}" do
        cwd "/tmp"
        code <<-EOF
          #{install_path}/bin/gem install #{gem} --force --no-rdoc --no-ri
        EOF
        not_if { ::File.exists?(pkg_path) }
      end
    end
  end

  fpm_cmd =
    case node['platform_family']
    when 'rhel', 'fedora'
      "fpm -s dir -t rpm -n ruby-#{ruby_version} -v #{pkg_version} -p ruby-pkg #{install_path}"
    when 'debian'
      "fpm -s dir -t deb -n ruby-#{ruby_version} -v #{pkg_version} -p ruby-pkg #{install_path}"
    end

  Chef::Log.debug("fpm command: #{fpm_cmd}")

  bash "package ruby #{ruby_version} with fpm" do
    cwd "/tmp"
    code <<-EOF
      #{fpm_cmd}
      mv ruby-pkg #{pkg_path}
      rm -rf #{install_path} /tmp/ruby-#{ruby_version} /tmp/ruby-#{ruby_version}.tar.gz
    EOF
    not_if { ::File.exists?(pkg_path) }
  end

  if aws_access_key_id && aws_secret_access_key && aws_bucket && aws_path
    ruby_block "uploading #{ruby_version} to S3" do
      block do
        require 'aws-sdk'
        s3 = AWS::S3.new(access_key_id: aws_access_key_id, secret_access_key: aws_secret_access_key)
        s3.client
        bucket = s3.buckets[ aws_bucket ]
        object = bucket.objects[ "#{aws_path}/#{pkg_file}" ]
        object.acl(:public_read) # FIXME: make into parameter
        object.write(Pathname.new(pkg_path))
      end
      subscribes :run, "ruby_block[package ruby #{ruby_version} with fpm]", :immediately
      action :nothing
    end
  end

  case node['platform_family']
  when 'rhel', 'fedora'
    rpm_package pkg_path
  when 'debian'
    dpkg_package pkg_path
  when 'arch'
    pacman_package pkg_path
  end
end
