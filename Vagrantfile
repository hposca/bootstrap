# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu"

  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :private_network, ip: "192.168.2.2"

  config.vm.provider :virtualbox do |vb|
    # vb.gui = true

    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

end
