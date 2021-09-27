# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |global|
  global.vm.box = "bento/rockylinux-8"
  global.vm.box_check_update = false

  # Turn off vbguest if installed as bento has guest additions installed
  global.vbguest.auto_update = false if Vagrant.has_plugin?("vagrant-vbguest")

  # Webserver
  global.vm.define "webserver" do |config|
    config.vm.hostname = "webserver.mywebapp.com"
    config.vm.network "private_network", ip: "192.168.33.10", netmask: "255.255.255.0"
    config.vm.provision :hosts, :sync_hosts => true
  end

  # Database Server
  global.vm.define "dbserver" do |config|
    config.vm.hostname = "dbserver.mywebapp.com"
    config.vm.network "private_network", ip: "192.168.33.20", netmask: "255.255.255.0"
    config.vm.provision :hosts, :sync_hosts => true
  end
end
