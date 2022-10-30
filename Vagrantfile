# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # Base VM OS configuration.
  config.vm.box = 'geerlingguy/rockylinux8'
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.vm.synced_folder '.', '/vagrant', disabled: true
  # Do not automatically update the guest ddtitions
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  # General VirtualBox VM configuration.
  config.vm.provider :virtualbox do |v|
    v.memory = 512
    v.cpus = 1
    v.linked_clone = true
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--ioapic', 'on']
  end

  # Webserver
  config.vm.define 'webserver' do |webserver|
    webserver.vm.hostname = 'webserver.mywebapp.com'
    webserver.vm.network 'private_network', ip: '192.168.33.10', virtualbox__intnet: 'webappstack'
    webserver.vm.network 'forwarded_port', guest: 80, host: 8080
    webserver.vm.network 'forwarded_port', guest: 443, host: 8443
    webserver.vm.provision :hosts, sync_hosts: true
    webserver.vm.provision 'shell', path: 'provision_webserver.sh'
    webserver.vm.provision 'shell', path: 'install_wordpress.sh', args: 'localhost:8080'
  end

  # Database Server
  config.vm.define 'dbserver' do |dbserver|
    dbserver.vm.hostname = 'dbserver.mywebapp.com'
    dbserver.vm.network 'private_network', ip: '192.168.33.20', virtualbox__intnet: 'webappstack'
    dbserver.vm.network 'forwarded_port', guest: 3306, host: 8306
    dbserver.vm.provision :hosts, sync_hosts: true
    dbserver.vm.provision 'shell', path: 'provision_dbserver.sh'
    dbserver.vm.provision 'shell', path: 'install_world.sh'
  end
end
