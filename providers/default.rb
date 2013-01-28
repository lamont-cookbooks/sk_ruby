
action :install do
  ruby_version = new_resource.version
  rubygems_version = new_resource.rubygems
  pkg_version = new_resource.pkg_version || "0.0.1"
  gems = new_resource.gems

  install_path = "/opt/ruby-#{ruby_version}"
  url = "ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-#{ruby_version}.tar.gz"
  arch = ( node[:kernel][:machine] == "x86_64" ) ? "amd64" : "i386"

  deb_file = "ruby-#{ruby_version}-#{pkg_version}_#{arch}.deb"
  deb_path = "#{Chef::Config[:file_cache_path]}/#{deb_file}"

  temp_dir= "/tmp/installdir"

  # FIXME: try to download precompiled deb file from S3 to cache

  bash "compile ruby #{ruby_version} from sources to deb file" do
    cwd "/tmp"
    code <<-EOH
      rm -rf /tmp/ruby-#{ruby_version}
      wget #{url}
      tar xvzf ruby-#{ruby_version}.tar.gz && cd ruby-#{ruby_version}
      ./configure --prefix=#{install_path}
      make
      mkdir #{temp_dir}
      make install DESTDIR=#{temp_dir}
    EOH
    not_if { ::File.exists?(deb_path) }
  end

  unless rubygems_version.nil?
    bash "install rubygems #{rubygems_version} into #{ruby_version}" do
      cwd "/tmp"
      code <<-EOH
        rm -rf /tmp/rubygems-#{rubygems_version}
        wget http://production.cf.rubygems.org/rubygems/rubygems-#{rubygems_version}.tgz
        tar -xvzf rubygems-#{rubygems_version}.tgz && cd rubygems-#{rubygems_version}
        #{temp_dir}/#{install_path}/bin/ruby setup.rb --no-format-executable
      EOH
      not_if { ::File.exists?(deb_path) }
    end

    gems.each do |gem|
      bash "install gem #{gem} into #{ruby_version}" do
        cwd "/tmp"
        code <<-EOH
          #{temp_dir}/#{install_path}/bin/gem install #{gem} --no-rdoc --no-ri
        EOH
        not_if { ::File.exists?(deb_path) }
      end
    end
  end


  bash "package ruby #{ruby_version} with fpm" do
    cwd "/tmp"
    code <<-EOH
      fpm -s dir -t deb -n ruby-#{ruby_version} -v #{pkg_version} -C #{temp_dir} -p ruby-#{ruby_version}-VERSION_ARCH.deb #{install_path.gsub(/^\/*/,"")}
      mv #{deb_file} #{deb_path}
      rm -rf #{temp_dir} /tmp/ruby-#{ruby_version} /tmp/ruby-#{ruby_version}.tar.gz
    EOH
    not_if { ::File.exists?(deb_path) }
  end

  dpkg_package deb_path

end

