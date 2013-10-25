Vagrant.configure("2") do |config|
  config.vm.box = "opscode-ubuntu-13.04"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-13.04_provisionerless.box"
  config.omnibus.chef_version = :latest
  config.vm.boot_timeout = 120
  config.vbguest.installer = CloudUbuntuVagrant

  #config.vm.network :forwarded_port, guest: 80, host: 8080
  #config.vm.synced_folder "shared", "/shared"

  config.berkshelf.enabled = true
  config.vm.provision :chef_client do |chef|
    chef.node_name = "sk_ruby_cookbook_testing"
    chef.run_list = [
      "sk_ruby"
    ]
  end
end
