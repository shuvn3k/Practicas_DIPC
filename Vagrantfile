# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

  VAGRANTFILE_API_VERSION = "2"

  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.ssh.forward_agent = true

    config.vm.define "server" do |server|
      server.vm.box = "boxcutter/ubuntu1604" 
      server.vm.network "private_network", ip: "192.168.34.150"
      server.vm.network :forwarded_port, guest:80, host: 8080
      server.vm.provision "file", source: "./tmp/default", destination: "/tmp/default"
      server.vm.provision "file", source: "./tmp/02-beats-input.conf", destination: "/tmp/02-beats-input.conf"
      server.vm.provision "file", source: "./tmp/10-syslog-filter.conf", destination: "/tmp/10-syslog-filter.conf"
      server.vm.provision "file", source: "./tmp/30-elasticsearch-output.conf", destination: "/tmp/30-elasticsearch-output.conf"
      server.vm.provision "shell", path: "server-provision.sh"
      server.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", "2048"]
        vb.customize ["modifyvm", :id, "--cpus", "4"]
      end
    end

    config.vm.define "cliente" do |cliente|
      cliente.vm.box = "boxcutter/ubuntu1604"
      cliente.vm.network  "private_network", ip: "192.168.34.151"
      cliente.vm.provision "shell", path: "cliente-linux-provision.sh"
      cliente.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", "512"]
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        
    end
    end
  end
