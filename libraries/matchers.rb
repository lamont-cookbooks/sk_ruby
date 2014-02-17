if defined?(ChefSpec)
  def download_sk_ruby(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby, :download, resource_name)
  end
  def install_sk_ruby(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby, :install, resource_name)
  end
  def install_sk_ruby_symlinks(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby_symlinks, :install, resource_name)
  end
end
