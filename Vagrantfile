
class CloudUbuntuVagrant < VagrantVbguest::Installers::Ubuntu
  def install(opts=nil, &block)
    communicate.sudo('sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list ', opts, &block)
    communicate.sudo('apt-get update', opts, &block)
    communicate.sudo('apt-get -y -q purge virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11', opts, &block)
    @vb_uninstalled = true
    super
  end

  def running?(opts=nil, &block)
    return false if @vb_uninstalled
    super
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "raring"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-amd64-vagrant-disk1.box"
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
