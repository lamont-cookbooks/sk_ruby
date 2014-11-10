
my_gems = %w{
  bundler
  rake
  pry
}

sk_ruby "2.1.0" do
  rubygems "2.2.1"
  gems my_gems
#  cache_uri_base "http://s3.scriptkiddie.org/nonexist"
  pkg_version "0.0.1"
  aws_path "/something"
  aws_bucket "mybucket"
  aws_access_key_id "AKIAIISJV5TZ3FPWU3TA"
  aws_secret_access_key "ABCDEFGHIJKLMNOP1234556/s"
  action :install
end

