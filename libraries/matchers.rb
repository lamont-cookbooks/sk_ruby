if defined?(ChefSpec)
  def download_sk_ruby(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby, :download, resource_name)
  end

  def compile_sk_ruby(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby, :compile, resource_name)
  end

  def upload_sk_ruby(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby, :upload, resource_name)
  end

  def install_sk_ruby(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby, :install, resource_name)
  end

  def install_sk_ruby_symlinks(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sk_ruby_symlinks, :install, resource_name)
  end
end
