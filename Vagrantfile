Vagrant.configure("2") do |config|
    config.vm.define "scriptbox" do |scriptbox|    
    scriptbox.vm.box = "spox/ubuntu-arm"
    scriptbox.vm.box_version = "1.0.0"
    scriptbox.vm.network "private_network", ip: "192.168.56.30"
    scriptbox.vm.hostname = "scriptbox"
    scriptbox.vm.provider "vmware_desktop" do |v|
      v.allowlist_verified = true
      v.ssh_info_public = true
        # v.gui = true
    end
    scriptbox.vm.provision "shell", inline: <<-SHELL
    #  sudo mv /etc/apt/sources.list /tmp/
     sudo apt clean
     sudo apt update
     sudo apt upgrade
     sudo systemctl stop ufw

    SHELL
  end
    config.vm.define "web01" do |web01|    
    web01.vm.box = "spox/ubuntu-arm"
    web01.vm.box_version = "1.0.0"
    web01.vm.network "private_network", ip: "192.168.56.31"
    web01.vm.hostname = "web01"
    web01.vm.provider "vmware_desktop" do |v|
      v.allowlist_verified = true
      v.ssh_info_public = true
        # v.gui = true
    end
    web01.vm.provision "shell", inline: <<-SHELL
    #  sudo mv /etc/apt/sources.list /tmp/
     sudo apt clean
     sudo apt update
     sudo systemctl stop ufw

    SHELL
  end
end
