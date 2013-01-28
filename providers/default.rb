
action :install do
  ruby_version = new_resource.version
  install_path = "/opt/ruby-#{ruby_version}"
  pkg_version = "0.0.1"
  url = "ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-#{ruby_version}.tar.gz"
  arch = ( node[:kernel][:machine] == "x86_64" ) ? "amd64" : "i386"

  deb_file = "ruby-#{ruby_version}-#{pkg_version}_#{arch}.deb"
  deb_path = "#{Chef::Config[:file_cache_path]}/#{deb_file}"

  # FIXME: try to download precompiled deb file from S3 to cache

  bash "compile ruby #{ruby_version} from sources to deb file" do
    cwd "/tmp"
    code <<-EOH
      rm -rf /tmp/ruby-#{ruby_version}
      wget #{url}
      tar xvzf ruby-#{ruby_version}.tar.gz && cd ruby-#{ruby_version}
      ./configure --prefix=#{install_path}
      make
      mkdir /tmp/installdir
      make install DESTDIR=/tmp/installdir
      fpm -s dir -t deb -n ruby-#{ruby_version} -v #{pkg_version} -C /tmp/installdir -p ruby-#{ruby_version}-VERSION_ARCH.deb #{install_path.gsub(/^\/*/,"")}
      mv #{deb_file} #{deb_path}
      rm -rf /tmp/installdir /tmp/ruby-#{ruby_version} /tmp/ruby-#{ruby_version}.tar.gz
    EOH
    not_if { ::File.exists?(deb_path) }
  end

  deb_package deb_path

end

