# absolutely will not fix this for Chef 10, do not ask
use_inline_resources

action :install do
  bin_path = new_resource.bin_path
  exclude = new_resource.exclude || []

  Dir[ ::File.join(bin_path, "*") ].each do |path|
    file = ::File.basename(path)
    unless exclude.include?(file)
      %w{/usr/local/bin /usr/bin}.each do |sysdir|
        link ::File.join(sysdir, file) do
          to path
          notifies :run, "ruby_block[clear gem paths]"
        end
      end
    end
  end

  ruby_block "clear gem paths" do
    block do
      Gem.clear_paths
    end
  end
end
