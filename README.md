coreos-pxe-sandbox
--

<!-- MarkdownTOC -->

- [TL;DR](#tldr)
  - [1 - Workspace setup](#1---workspace-setup)
  - [2 - Vagrant boxes](#2---vagrant-boxes)
  - [3 - Provisioning follow-up](#3---provisioning-follow-up)
- [Details overview](#details-overview)
- [Description](#description)
  - [VBox topology](#vbox-topology)
  - [Requirements](#requirements)
- [Demos](#demos)
  - [1 - Up the sandbox environment](#1---up-the-sandbox-environment)
  - [2 - Cluster Bootstrapping with Mayu](#2---cluster-bootstrapping-with-mayu)
  - [3 - CoreOS Update-engine usage and management](#3---coreos-update-engine-usage-and-management)

<!-- /MarkdownTOC -->


## TL;DR

Workshop demo repo for [CoreOS Paris UG Meetup slides](20160719_CoreOS_1-cluster-bootstrapping.pdf)

### 1 - Workspace setup

Before starting, **checkout the submodules** needed for provisioning the VMs:

```
$ git clone https://github.com/xakraz/coreos-pxe-sandbox.git && cd coreos-pxe-sandbox
$ git submodule init
$ git submodule update
```


### 2 - Vagrant boxes

Let's have a quick overlook of the VMs that Vagrant will create:

```
$ vagrant status
Current machine states:

core-provisioner          not created (virtualbox)
core-01                   not created (virtualbox)
core-02                   not created (virtualbox)
core-03                   not created (virtualbox)
```


First, **UP the provisioner** host

```
$ vagrant up core-provisioner
```


Then boot the nodes

```
$ vagrant up --parallel /core-0/
```


#### Notes

>
> Have a look at [vagrant's provisioning config variables](scripts/config.bash) to customize or update the versions of  `Mayu` and CoreOS images.
>


### 3 - Provisioning follow-up

Profit :)

```
$ vagrant ssh core-provisioner
core@prov ~ $ docker ps -a
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS               NAMES
41007d9286fa        giantswarm/mayu:0.11.1   "mayu --cluster-direc"   3 hours ago         Up 3 hours                              mayu
```


```
$ vagrant ssh core-provisioner
core@prov ~ $ watch -n 5 'giantswarm-mayu/mayu.0.11.1-linux-amd64/mayuctl --no-tls list'

Every 5.0s: ./mayuctl --debug --no-tls list                                                                    Tue Jul 19 10:44:14 2016

IP            SERIAL          PROFILE        IPMIADDR  PROVIDERID  ETCDTOKEN                         METADATA        COREOS    STATE   LASTBOOT
192.168.2.21  0800278e158a-0  core-services  -         -           a1980e85fd8527103545e92d3eb5c48f  role-core=true  1068.6.0  "running"  2016-07-19 10:43:20
192.168.2.22  0800278e158b-1  core-services  -         -           a1980e85fd8527103545e92d3eb5c48f  role-core=true  1068.6.0  "running"  2016-07-19 10:43:36
192.168.2.23  0800278e158c-2  core-services  -         -           a1980e85fd8527103545e92d3eb5c48f  role-core=true  1068.6.0  "running"  2016-07-19 10:43:45
```



## Details overview

This repo contains a Vagrant setup to experiment **cluster provisioning** of [CoreOS](https://coreos.com/) instances with [Mayu](https://github.com/giantswarm/mayu/), a tool provided by [GiantSwam](https://giantswarm.io/products/).

The goal is to have a "sandbox" environment where it is easy to try and test **bootstrapping on Baremetal**, the automated way (As you may need in a company).

Other useful links:
* https://github.com/coreos/coreos-vagrant
* https://github.com/coreos/coreos-baremetal
* https://blog.giantswarm.io/mayu-yochu-provisioning-tools-for-coreos-bare-metal/



## Description

### VBox topology

![Vagrant setup](https://github.com/xakraz/coreos-pxe-sandbox/blob/master/img/20160719_CoreOS_1-cluster-bootstraping.png)

#### Nodes

* `core-provisoner`: This node is 1 CoreOS instance. We are using the vagrant box provided by CoreOS (Already "provisioned", chicken / egg problem ^^). Every tools and softwares we will need to setup the PXE environment will run on this node into containers. It is much easier that way and the final goal of bootstrapping such infrastructure any way :)

* `core-0x`: The other nodes are using a vagrant box especially built for network-boot and are blank. The interesting part is in the "machine" configuration from VBox.

#### Networks

* `Vboxnet0`: The default bridge interface created by VirtualBox. On this interface, VBox has a DNS and a DHCP service. The VMs using this network have access to the internet via NAT. We can not reach the VMs behind this interface.
* `Vboxnet1`: This is a "private network" were we can access the VMs directly from the host but the VMs are not reachable from "outside" the hosts. It is a totally different network than the one that the host machine use.

> Note: In our setup, the `core-provisioner` VM will be the network **gateway** of our "private_network".


### Requirements

* `Vagrant` > 1.6.0
* `Virtualbox`
* `Virtualbox-extension-pack` (For the PXE setup, needing some HW Network drivers for the VM)




## Demos

### 1 - Up the sandbox environment

[demo-1](docs/demo-1.md)


### 2 - Cluster Bootstrapping with Mayu

[demo-2](docs/demo-2.md)

### 3 - CoreOS Update-engine usage and management

[demo-3](docs/demo-3.md)






