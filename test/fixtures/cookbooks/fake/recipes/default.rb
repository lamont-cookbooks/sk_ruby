
include_recipe 'sk_ruby'

my_gems = %w{
  bundler
  rake
  pry
}

sk_ruby "1.8.7-p374" do
  rubygems "1.8.18"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/nonexist"
  pkg_version "0.0.1"
end

sk_ruby "1.9.3-p484" do
  rubygems "2.2.1"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/nonexist"
  pkg_version "0.0.1"
end

sk_ruby "2.0.0-p353" do
  rubygems "2.2.1"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/nonexist"
  pkg_version "0.0.1"
end

sk_ruby "2.1.0" do
  rubygems "2.2.1"
  gems my_gems
  cache_uri_base "http://s3.scriptkiddie.org/nonexist"
  pkg_version "0.0.1"
end

sk_ruby_symlinks "/opt/ruby-2.1.0/bin"
