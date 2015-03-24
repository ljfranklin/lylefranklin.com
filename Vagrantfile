# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  
  config.vm.network "forwarded_port", guest: 4567, host: 4567

  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  # mount scripts so they can be referenced by other scripts
  config.vm.synced_folder "install-scripts", "/home/vagrant/install-scripts"

  config.vm.provision "shell", path: "install-scripts/customize-shell"
  config.vm.provision "shell", path: "install-scripts/install-git"
  config.vm.provision "shell", path: "install-scripts/install-ruby"
  config.vm.provision "shell", path: "install-scripts/install-middleman"
  config.vm.provision "shell", path: "install-scripts/install-js-tools"

end
