coreos-pxe-sandbox
--

<!-- MarkdownTOC -->

- [Overview](#overview)
- [Description](#description)
  - [VBox topology](#vbox-topology)
    - [Nodes](#nodes)
    - [Networks](#networks)
  - [Requirements](#requirements)
- [Demos](#demos)
  - [Cluster Bootstrapping with Mayu](#cluster-bootstrapping-with-mayu)
  - [CoreOS Update-engine usage and management](#coreos-update-engine-usage-and-management)

<!-- /MarkdownTOC -->



# Overview

This repo contains a Vagrant setup to experiment provisioning a **cluster** of [CoreOS](https://coreos.com/) instances with [Mayu](https://github.com/giantswarm/mayu/), a tool provided by [GiantSwam](https://giantswarm.io/products/).

The goal is to setup a "sandbox" environment for easy bootstrapping in a **Baremetal** use-case.

Other useful links:
* https://github.com/coreos/coreos-vagrant
* https://github.com/coreos/coreos-baremetal
* https://blog.giantswarm.io/mayu-yochu-provisioning-tools-for-coreos-bare-metal/
* [CoreOS Paris UG Meetup slides](20160719_CoreOS_1-cluster-bootstrapping.pdf)



# Description

## VBox topology

![Vagrant setup](https://github.com/xakraz/coreos-pxe-sandbox/blob/master/img/20160719_CoreOS_1-cluster-bootstraping.png)

### Nodes

* `core-provisoner`: This node is 1 CoreOS instance (Using the vagrant box provided by CoreOS). Every tools and software we will need to setup the PXE environment will run on this node into containers. It is much easier that way and the final goal of bootstrapping such infrastructure any way :)

* `core-0x`: The other nodes are using a vagrant box especially built for network-boot and are blank. The interesting part is in the "machine" configuration from VBox.

### Networks

* `Vboxnet0`: The default bridge interface created by VirtualBox. On this interface, VBox has a DNS and a DHCP service. The VMs using this network have access to the internet via NAT. We can not reach the VMs behind this interface.
* `Vboxnet1`: This is a "private network" were we can access the VMs directly from the host but the VMs are not reachable from "outside" the hosts. It is a totally different network than the one that the host machine use.

> Note: In our setup, the `core-provisioner` VM will be the network gateway of our "private_network".


## Requirements

* `Vagrant` > 1.6.0
* `Virtualbox`
* `Virtualbox-extension-pack` (For the PXE setup, needing some HW Network drivers for the VM)



# Demos

## Cluster Bootstrapping with Mayu

## CoreOS Update-engine usage and management

