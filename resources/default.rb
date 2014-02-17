actions :download, :install
default_action [ :download, :install ]

attribute :version,        kind_of: String, name_attribute: true
attribute :rubygems,       kind_of: String
attribute :pkg_version,    kind_of: String
attribute :gems,           kind_of: Array
attribute :cache_uri_base, kind_of: String
attribute :install_path,   kind_of: String
attribute :ruby_url,       kind_of: String
attribute :pkg_file,       kind_of: String

attribute :aws_access_key_id,     kind_of: String
attribute :aws_secret_access_key, kind_of: String
attribute :aws_bucket,            kind_of: String
attribute :aws_path,              kind_of: String
