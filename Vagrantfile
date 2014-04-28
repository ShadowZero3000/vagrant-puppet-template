Vagrant.configure("2") do |config|
  config.vm.box = "Ubuntu precise 64 PuppetLabs VirtualBox"
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box"
  config.vm.network "private_network", ip:"192.168.56.5"
  config.vm.network "public_network"
  config.vm.provider "virtualbox" do |v|
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
  end

  config.vm.provision :shell, :path => "setup/bootstrap.sh"
end