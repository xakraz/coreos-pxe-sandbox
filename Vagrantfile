# -*- mode: ruby -*-
# # vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.6.0"

# = Variables
#
# Defaults for config options defined in CONFIG
$update_channel = "alpha"
$image_version  = "current"
$instance_name_prefix = "core"


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
    prov_ip = "192.168.2.2"

    prov.vm.box     = "coreos-%s" % $update_channel
    prov.vm.box_url = "https://storage.googleapis.com/%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]

    prov.vm.hostname = "prov"
    prov.vm.network "private_network", ip: prov_ip
    #prov.vm.network "public_network", :adapter=>1, auto_config: false

    #prov.ssh.host = prov_ip
  end


  # == The CoreOS nodes
  #
  [["192.168.2.3", "0800278E158A"],
   ["192.168.2.4", "0800278E158B"],
   ["192.168.2.5", "0800278E158C"]].collect.each_with_index do |data, index|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, index + 1 ] do |node|
      ip  = data[0]
      mac = data[1]

      node.vm.hostname = vm_name

      # Use a image designed for pxe boot.
      node.vm.box = "clink15/pxe"

      # Give the host a bogus IP, otherwise vagrant will bail out.
      # Static mac address match up with dnsmasq dhcp config
      # The auto_config: false tells vagrant not to change the hosts ip to the bogus one.
      node.vm.network "private_network", :adapter=>1, ip: "192.168.2.24#{index}", :mac => mac , auto_config: false

      # We dont need no stinking synced folder.
      config.vm.synced_folder '.', '/vagrant', disabled: true

      # Use the ip we gets assigned from dhcp when 'vagrant ssh'
      node.ssh.host     = ip
      node.ssh.username = 'core'


      node.vm.provider "virtualbox" do |vb, override|
        # vb.gui = true
        # Chipset needs to be piix3, otherwise the machine wont boot properly.
        vb.customize ["modifyvm", :id, "--chipset", "piix3"]
      end
    end
  end
end
