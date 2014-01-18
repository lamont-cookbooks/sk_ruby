actions :install

attribute :bin_path, :kind_of => String, :name_attribute => true
# don't ever overwrite omnibus-installed chef utils by default
attribute :exclude, :kind_of => Array, :default => [ 'chef-client', 'knife', 'chef-solo', 'chef-shell', 'chef-apply', 'ohai', 'shef' ]

def initialize(*args)
  super
  @action = :install
end
