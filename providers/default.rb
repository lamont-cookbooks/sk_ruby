
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

  # FIXME: if we have aws_* attributes then we should s3_file download using those creds
  if cache_uri_base
    cache_uri = "#{cache_uri_base}/#{deb_file}"
    Chef::Log.debug("sk_ruby cache_uri: #{cache_uri}")
    remote_file deb_path do
      source cache_uri
      action :create
      only_if { system("curl -s -I -L -m 30 --retry 5 --retry-delay 1 #{cache_uri} | head -n 1 | grep 200 >/dev/null 2>&1") }
    end
  end

  bash "compile ruby #{ruby_version} from sources" do
    cwd "/tmp"
    code <<-EOH
      rm -rf /tmp/ruby-#{ruby_version}
      rm -f /tmp/ruby-#{ruby_version}.tar.gz
      wget #{url}
      tar xzf ruby-#{ruby_version}.tar.gz && cd ruby-#{ruby_version}
      ./configure --prefix=#{install_path} --disable-install-doc
      make -j 3
      rm -rf #{install_path}
      make install
    EOH
    not_if { ::File.exists?(deb_path) }
  end

  if rubygems_version
    bash "install rubygems #{rubygems_version} into #{ruby_version}" do
      cwd "/tmp"
      code <<-EOH
        rm -rf /tmp/rubygems-#{rubygems_version}
        rm -f /tmp/rubygems-#{rubygems_version}.tgz
        wget http://production.cf.rubygems.org/rubygems/rubygems-#{rubygems_version}.tgz
        tar -xzf rubygems-#{rubygems_version}.tgz && cd rubygems-#{rubygems_version}
        #{install_path}/bin/ruby setup.rb --no-format-executable
      EOH
      environment 'LC_ALL' => 'en_US.utf-8' # rubygems 2.0.3 hack
      not_if { ::File.exists?(deb_path) }
    end

    gems.each do |gem|
      bash "install gem #{gem} into #{ruby_version}" do
        cwd "/tmp"
        code <<-EOH
          #{install_path}/bin/gem install #{gem} -V --force --no-rdoc --no-ri
        EOH
        not_if { ::File.exists?(deb_path) }
      end
    end
  end

  bash "package ruby #{ruby_version} with fpm" do
    cwd "/tmp"
    code <<-EOH
      fpm -s dir -t deb -n ruby-#{ruby_version} -v #{pkg_version} -p ruby-#{ruby_version}-VERSION_ARCH.deb #{install_path}
      mv ruby-#{ruby_version}-#{pkg_version}_#{arch}.deb  #{deb_path}
      rm -rf #{install_path} /tmp/ruby-#{ruby_version} /tmp/ruby-#{ruby_version}.tar.gz
    EOH
    not_if { ::File.exists?(deb_path) }
    notifies :run, "ruby_block[uploading #{ruby_version} to S3]", :immediately
  end

  if aws_access_key_id && aws_secret_access_key && aws_bucket && aws_path
    ruby_block "uploading #{ruby_version} to S3" do
      block do
        require 'aws-sdk'
        s3 = AWS::S3.new(:access_key_id => aws_access_key_id, :secret_access_key => aws_secret_access_key)
        s3.client
        bucket = s3.buckets[ aws_bucket ]
        object = bucket.objects[ "#{aws_path}/#{deb_file}" ]
        object.write(Pathname.new(deb_path))
      end
      action :nothing
    end
  end

  dpkg_package deb_path

end
