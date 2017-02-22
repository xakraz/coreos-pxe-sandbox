# -*- mode: ruby -*-
# # vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.6.0"

# = Variables
#
# Defaults for config options for CoreOS Vagrant image
$update_channel   = "alpha"
#$image_version    = "current"
$image_version    = "1032.1.0"
$node_name_prefix = "core"

# Network variables
$private_subnet = '192.168.2'


# = Vagrant VMs playground
#
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  # == The Provisioner
  #
  # Gateway, dhcp, pxe machine
  config.vm.define "core-provisioner" do |prov|

    # Plugins configuration for this manager
    if Vagrant.has_plugin?("vagrant-cachier")
      prov.cache.scope = :box
    end

    if Vagrant.has_plugin?("vagrant-vbguest") then
      config.vbguest.auto_update = false
    end

    # Vagrant provider tweaks
    prov.vm.provider :virtualbox do |vb|
      # On VirtualBox, we don't have guest additions or a functional vboxsf
      # in CoreOS, so tell Vagrant that so it can be smarter.
      vb.check_guest_additions = false
      vb.functional_vboxsf     = false
    end

    # VM Instance config
    prov_ip = "#{$private_subnet}.2"

    prov.vm.box     = "coreos-%s" % $update_channel
    prov.vm.box_url = "https://storage.googleapis.com/%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]

    prov.vm.hostname = "prov"
    prov.vm.network "private_network", ip: prov_ip
    #prov.vm.network "public_network", :adapter=>1, auto_config: false

    #prov.ssh.host = prov_ip

    # Configure the CoreOS instance
    prov.vm.provision "file", source: "scripts", destination: "~/"
    prov.vm.provision "shell" do |s|
      s.name           = "Setup Bats"
      s.inline         = "/bin/bash /home/core/scripts/bats/install.sh /opt"
      s.privileged     = true
    end
    prov.vm.provision "shell" do |s|
      s.name           = "Fetch MAYU"
      s.inline         = "/home/core/scripts/2-fetch-mayu.sh"
      s.env            = {
        PATH: "/opt/libexec:${PATH}"
      }
      s.privileged     = true
    end
    prov.vm.provision "shell" do |s|
      s.name           = "Fetch PXE assets"
      s.inline         = "/home/core/scripts/3-fecth-mayu-assets.sh"
      s.env            = {
        PATH: "/opt/libexec:${PATH}"
      }
      s.privileged     = true
    end
    prov.vm.provision "shell" do |s|
      s.name           = "Start MAYU"
      s.inline         = "/home/core/scripts/4-run-mayu-docker.sh"
      s.env            = {
        PATH: "/opt/libexec:${PATH}"
      }
      s.privileged     = true
    end
    prov.vm.provision "shell" do |s|
      s.name           = "Start Coreroller"
      s.inline         = "/home/core/scripts/5-run-coreroller.sh"
      s.env            = {
        PATH: "/opt/libexec:${PATH}"
      }
      s.privileged     = true
    end
    prov.vm.provision "shell" do |s|
      s.name           = "Setup network"
      s.inline         = "/home/core/scripts/1-setup-gateway.sh"
      s.env            = {
        PATH: "/opt/libexec:${PATH}"
      }
      s.privileged     = true
    end
    prov.vm.provision "shell" do |s|
      s.name           = "Stop update-engine"
      s.inline         = "/home/core/scripts/6-coreos-disable-update-engine.sh"
      s.env            = {
        PATH: "/opt/libexec:${PATH}"
      }
      s.privileged     = true
    end
    prov.vm.provision "shell" do |s|
      s.name           = "Final tests"
      s.inline         = "/home/core/scripts/7-validation.sh"
      s.env            = {
        PATH: "/opt/libexec:${PATH}"
      }
      s.privileged     = true
    end


    # File sharing
    prov.vm.synced_folder ::File.join(::File.dirname(__FILE__), 'shared'), "/home/core/shared",
      type: "rsync",
      rsync__args: ["--verbose", "--archive","--compress"]
  end


  # == The CoreOS nodes
  #
  [["#{$private_subnet}.21", "0800278E158A"],
   ["#{$private_subnet}.22", "0800278E158B"],
   ["#{$private_subnet}.23", "0800278E158C"]].collect.each_with_index do |data, index|
    config.vm.define vm_name = "%s-%02d" % [$node_name_prefix, index + 1 ] do |node|
      ip  = data[0]
      mac = data[1]

      node.vm.hostname = vm_name

      # Use a image designed for pxe boot.
      node.vm.box = "clink15/pxe"
      node.vm.boot_timeout = 3600

      # Give the host a bogus IP, otherwise vagrant will bail out.
      # Static mac address match up with dnsmasq dhcp config
      # The auto_config: false tells vagrant not to change the hosts ip to the bogus one.
      node.vm.network "private_network", :adapter=>1, ip: "#{$private_subnet}.24#{index}", :mac => mac , auto_config: false

      # We dont need no stinking synced folder.
      node.vm.synced_folder '.', '/vagrant', disabled: true

      # Use the ip we gets assigned from dhcp when 'vagrant ssh'
      node.ssh.host     = ip
      node.ssh.username = 'core'


      # Virtualbox provider tweaks
      node.vm.provider "virtualbox" do |vb, override|
        # vb.gui = true
        # Chipset needs to be piix3, otherwise the machine wont boot properly.
        vb.customize ["modifyvm", :id, "--chipset", "piix3"]

        # By default, VBox sets the VM serial number to 0
        # This hack sets a different, but predicatable serial_number to the nodes VMs
        # Mayu uses serial_number as a uuid for servers
        vb.customize ["setextradata", :id, "VBoxInternal/Devices/pcbios/0/Config/DmiSystemSerial", "string:#{mac}-#{index}"]
      end

      # Configure the CoreOS instance
      node.vm.provision "file", source: "scripts", destination: "~/"
      node.vm.provision "shell" do |s|
        s.name           = "Setup Bats"
        s.inline         = "/bin/bash /home/core/scripts/bats/install.sh /opt"
        s.privileged     = true
      end
      node.vm.provision "shell" do |s|
        s.name           = "Nodes post-install"
        s.inline         = "/home/core/scripts/nodes-post-install.sh"
        s.env            = {
          PATH: "/opt/libexec:${PATH}"
        }
        s.privileged     = true
      end
    end
  end
end
