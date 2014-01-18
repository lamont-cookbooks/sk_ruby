action :install do
  bin_path = new_resource.bin_path
  exclude = new_resource.exclude || []

  Dir[ ::File.join(bin_path, "*") ].each do |path|
    file = ::File.basename(path)
    unless exclude.include?(file)
      %w{/usr/local/bin /usr/bin}.each do |sysdir|
        link ::File.join(sysdir, file) do
          to path
        end
      end
    end
  end

  ruby_block "clear gem paths" do
    # FIXME: notify based on link providers
    block do
      Gem.clear_paths
    end
  end
end
