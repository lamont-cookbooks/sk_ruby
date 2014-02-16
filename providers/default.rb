
# absolutely will not fix this for Chef 10, do not ask
use_inline_resources

action :install do
  ruby_version = new_resource.version
  # major.minor version for "2.0.0-p195" => "2.0"
  ruby_major_minor_version = new_resource.version[/^(\d+\.\d+)/, 1]
  rubygems_version = new_resource.rubygems
  pkg_version = new_resource.pkg_version || "0.0.1"
  cache_uri_base = new_resource.cache_uri_base
  gems = new_resource.gems

  aws_access_key_id = new_resource.aws_access_key_id
  aws_secret_access_key = new_resource.aws_secret_access_key
  aws_bucket = new_resource.aws_bucket
  aws_path = new_resource.aws_path

  install_path = new_resource.install_path || "/opt/ruby-#{ruby_version}"
  url = new_resource.ruby_url || "ftp://ftp.ruby-lang.org//pub/ruby/#{ruby_major_minor_version}/ruby-#{ruby_version}.tar.gz"
  arch = node[:kernel][:machine] == "x86_64" ? "amd64" : "i386"
  platform = "#{node[:platform]}_#{node[:platform_version]}".gsub(/\./, "_")
  deb_file = new_resource.deb_file || "ruby-#{ruby_version}-#{pkg_version}_#{platform}_#{arch}.deb"
  deb_path = "#{Chef::Config[:file_cache_path]}/#{deb_file}"

  if aws_access_key_id && aws_secret_access_key && aws_bucket && aws_path
    sk_s3_file deb_path do
      remote_path "#{aws_path}/#{deb_file}"
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
    cache_uri = "#{cache_uri_base}/#{deb_file}"
    Chef::Log.debug("sk_ruby cache_uri: #{cache_uri}")
    remote_file deb_path do
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
  file deb_path do
    action :delete
    only_if { ::File.zero?(deb_path) }
  end

  bash "compile ruby #{ruby_version} from sources" do
    cwd "/tmp"
    code <<-EOF
      rm -rf /tmp/ruby-#{ruby_version}
      rm -f /tmp/ruby-#{ruby_version}.tar.gz
      wget #{url}
      tar xzf ruby-#{ruby_version}.tar.gz && cd ruby-#{ruby_version}
      ./configure --prefix=#{install_path} --disable-install-doc
      make -j 3
      rm -rf #{install_path}
      make install
    EOF
    not_if { ::File.exists?(deb_path) }
  end

  if rubygems_version
    bash "install rubygems #{rubygems_version} into #{ruby_version}" do
      cwd "/tmp"
      code <<-EOF
        rm -rf /tmp/rubygems-#{rubygems_version}
        rm -f /tmp/rubygems-#{rubygems_version}.tgz
        wget http://production.cf.rubygems.org/rubygems/rubygems-#{rubygems_version}.tgz
        tar -xzf rubygems-#{rubygems_version}.tgz && cd rubygems-#{rubygems_version}
        #{install_path}/bin/ruby setup.rb --no-format-executable
      EOF
      environment 'LC_ALL' => 'en_US.utf-8' # rubygems 2.0.3 hack
      not_if { ::File.exists?(deb_path) }
    end

    gems.each do |gem|
      bash "install gem #{gem} into #{ruby_version}" do
        cwd "/tmp"
        code <<-EOF
          #{install_path}/bin/gem install #{gem} -V --force --no-rdoc --no-ri
        EOF
        not_if { ::File.exists?(deb_path) }
      end
    end
  end

  bash "package ruby #{ruby_version} with fpm" do
    cwd "/tmp"
    code <<-EOF
      fpm -s dir -t deb -n ruby-#{ruby_version} -v #{pkg_version} -p ruby-#{ruby_version}-VERSION_ARCH.deb #{install_path}
      mv ruby-#{ruby_version}-#{pkg_version}_#{arch}.deb  #{deb_path}
      rm -rf #{install_path} /tmp/ruby-#{ruby_version} /tmp/ruby-#{ruby_version}.tar.gz
    EOF
    not_if { ::File.exists?(deb_path) }
  end

  if aws_access_key_id && aws_secret_access_key && aws_bucket && aws_path
    ruby_block "uploading #{ruby_version} to S3" do
      block do
        require 'aws-sdk'
        s3 = AWS::S3.new(:access_key_id => aws_access_key_id, :secret_access_key => aws_secret_access_key)
        s3.client
        bucket = s3.buckets[ aws_bucket ]
        object = bucket.objects[ "#{aws_path}/#{deb_file}" ]
        object.acl(:public_read) # FIXME: make into parameter
        object.write(Pathname.new(deb_path))
      end
      subscribes :run, "ruby_block[package ruby #{ruby_version} with fpm]", :immediately
      action :nothing
    end
  end

  dpkg_package deb_path

end
