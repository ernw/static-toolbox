# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
    apt update
    apt install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
    apt install -y docker-engine
    service docker start
    apt install -y python3-pip
    pip3 install --upgrade pip
    pip3 install docker-compose
    systemctl daemon-reload
    systemctl restart docker
  SHELL
end
