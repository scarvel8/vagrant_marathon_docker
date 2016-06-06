# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  numNodes = 3 
  i = 0
  config.vm.box = "ubuntu/trusty64"

  (1...numNodes+1).each do |index|
    config.vm.define "mmdnode#{index}" do |nconfig|
      nconfig.vm.box = "ubuntu/trusty64"
      nconfig.vm.network(:private_network, :ip => "10.100.10.#{10+index}")
      nconfig.vm.host_name = "mmdnode#{index}"
      nconfig.vm.provider "virtualbox" do |vb|
         vb.memory = "1024"
      end
      nconfig.vm.provision "shell", inline: <<-SHELL
       # auto accept java license for noninteractive installs
       echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
       puppet module install garethr-docker; true
       puppet module install rcoleman/puppet_module; true
       puppet module install deric-zookeeper; true
       puppet module install deric-mesos; true
       # auto accept java license for noninteractive installs
       if [ ! -f /etc/puppet/hiera.yaml ];
       then
          ln -s /vagrant/puppet/hiera.yaml /etc/puppet/hiera.yaml
          echo zookeeper::id: '#{index}' > /etc/puppet/common.yaml
          echo zookeeper_servers: >> /etc/puppet/common.yaml
          for i in `seq 1 #{numNodes}`;
          do
             echo "- '10.100.10.$((i+10))'" >> /etc/puppet/common.yaml
          done
          echo mmdnode_hosts: >> /etc/puppet/common.yaml
          for i in `seq 1 #{numNodes}`;
          do
             echo "   mmdnode$i:" >> /etc/puppet/common.yaml
             echo "      ip: 10.100.10.$((i+10))" >> /etc/puppet/common.yaml
          done
       fi       
      SHELL
      nconfig.vm.provision "puppet" do |puppet|
        puppet.manifests_path = "puppet/manifests"
	puppet.manifest_file = "site.pp"
        puppet.module_path = "puppet/modules"
      end
    end
  end
end
