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
  - [Up the Sandbox environment](#up-the-sandbox-environment)
  - [Cluster Bootstrapping with Mayu](#cluster-bootstrapping-with-mayu)
  - [CoreOS Update-engine usage and management](#coreos-update-engine-usage-and-management)

<!-- /MarkdownTOC -->



# Overview

This repo contains a Vagrant setup to experiment provisioning a **cluster** of [CoreOS](https://coreos.com/) instances with [Mayu](https://github.com/giantswarm/mayu/), a tool provided by [GiantSwam](https://giantswarm.io/products/).

The goal is to setup a "sandbox" environment where it is easy to try bootstrapping / provisoning in a **Baremetal** use-case.

Other useful links:
* https://github.com/coreos/coreos-vagrant
* https://github.com/coreos/coreos-baremetal
* https://blog.giantswarm.io/mayu-yochu-provisioning-tools-for-coreos-bare-metal/
* [CoreOS Paris UG Meetup slides](20160719_CoreOS_1-cluster-bootstrapping.pdf)



# Description

## VBox topology

![Vagrant setup](https://github.com/xakraz/coreos-pxe-sandbox/blob/master/img/20160719_CoreOS_1-cluster-bootstraping.png)

### Nodes

* `core-provisoner`: This node is 1 CoreOS instance. We are using the vagrant box provided by CoreOS (Already "provisioned", chicken / egg problem ^^). Every tools and softwares we will need to setup the PXE environment will run on this node into containers. It is much easier that way and the final goal of bootstrapping such infrastructure any way :)

* `core-0x`: The other nodes are using a vagrant box especially built for network-boot and are blank. The interesting part is in the "machine" configuration from VBox.

### Networks

* `Vboxnet0`: The default bridge interface created by VirtualBox. On this interface, VBox has a DNS and a DHCP service. The VMs using this network have access to the internet via NAT. We can not reach the VMs behind this interface.
* `Vboxnet1`: This is a "private network" were we can access the VMs directly from the host but the VMs are not reachable from "outside" the hosts. It is a totally different network than the one that the host machine use.

> Note: In our setup, the `core-provisioner` VM will be the network **gateway** of our "private_network".


## Requirements

* `Vagrant` > 1.6.0
* `Virtualbox`
* `Virtualbox-extension-pack` (For the PXE setup, needing some HW Network drivers for the VM)



# Demos

## Up the Sandbox environment

Before starting, this is a quick overlook of the VMs that Vagrant will create:

```
$ vagrant status
Current machine states:

core-provisioner          not created (virtualbox)
core-01                   not created (virtualbox)
core-02                   not created (virtualbox)
core-03                   not created (virtualbox)
```


First, UP the provisioner host

```
$ vagrant up core-provisioner

```


What it does, described in the Vagrantfile, is:
* Get the Vagrant box from CoreOS.com
* Disable some features from VBox (since CoreOS is not a regular distro)
* Sends the "Provisioning" scripts to the VM
* Run them
  - Install BATS testing framework (For a nicer output)
  - Activate `IP_FORWARDING` and comfigure `IPTABLES`
* And finaly sync the "shared" resources to the `core-provisioner`


> Note:
> --
>
> We are using RSYNC for file sharing since NFS is not enabled by default on CoreOS.
> But you can use it if you wish to use a CoreOS Box as you development environment :)
>



## Cluster Bootstrapping with Mayu

## CoreOS Update-engine usage and management


