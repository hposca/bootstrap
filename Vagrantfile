# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # config.vm.box = "bento/ubuntu-16.04"
  # config.vm.box = "epipho/mint-20.0"
  # config.vm.box = "aaronvonawesome/linux-mint-20-cinnamon"
  config.vm.box = "ubuntu/jammy64"
  # Disabling automatically update check
  # To force update:
  # vagrant box update
  config.vm.box_check_update = false

  config.vm.network :private_network, ip: "192.168.2.2"

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider :virtualbox do |vb|
    # vb.gui = true
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  # Install it with
  # vagrant plugin install vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end
