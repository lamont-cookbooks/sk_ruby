if Gem::Requirement.new("<= 12.1.0").satisfied_by?(Gem::Version.new(Chef::VERSION))
  default['build-essential']['compile_time'] = true
end
