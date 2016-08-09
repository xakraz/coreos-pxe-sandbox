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
  - [1 - Up the sandbox environment](#1---up-the-sandbox-environment)
  - [2 - Cluster Bootstrapping with Mayu](#2---cluster-bootstrapping-with-mayu)
    - [Why Mayu ?](#why-mayu-)
    - [Mayu config overview](#mayu-config-overview)
    - [Step by Step bootstrapping](#step-by-step-bootstrapping)
  - [3 - CoreOS Update-engine usage and management](#3---coreos-update-engine-usage-and-management)

<!-- /MarkdownTOC -->



# Overview

This repo contains a Vagrant setup to experiment provisioning a **cluster** of [CoreOS](https://coreos.com/) instances with [Mayu](https://github.com/giantswarm/mayu/), a tool provided by [GiantSwam](https://giantswarm.io/products/).

The goal is to have a "sandbox" environment where it is easy to try and test bootstrapping in a **Baremetal** use-case, the automated way (As you may need in a company).

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

## 1 - Up the sandbox environment

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
* Sends the ["Provisioning" scripts](scripts/) to the VM
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



## 2 - Cluster Bootstrapping with Mayu

### Why Mayu ?

There are several ways to setup a PXE boot environment and it is different in every company.

CoreOS has recently started the [`core-baremetal`](https://github.com/coreos/coreos-baremetal) project that is pretty close to what `mayu` offers.

However `mayu` is really interesting for the following reasons:
- It **can integrate** into an exsiting PXE boot environment (it is an other HTTP service that provides resources after PXE)
- It **can be an "all-in one"** solution when using the container image (Contrary to `coreos-baremetal/bootcfg` which needs the other infrastructure components)
- It has **templating support** for complex and modular configuration file support
- It has an [**audit feature**](https://github.com/giantswarm/mayu/blob/master/docs/running.md) using `Git`
- And a HTTP RestAPI + client [`maycuctl`](https://github.com/giantswarm/mayu/blob/master/docs/mayuctl.md) that allows you to [**manage the life cycle**](https://github.com/giantswarm/mayu/blob/master/docs/machine_state_transition.md) of the servers from the same place


### Mayu config overview

To run mayu, you can follow the very good documenation from the project repo.
But we will provide a quick overview.

#### Features

Mayu (the container image) provides 4 main functions:
- DHCP server, *providing an IP via BootP*
- PXE server, *answering PXE protocol*
- TFTP server, *to send Kernel and Images*
- + an HTTP service for
  + the BootConfig (iPXE, Grub, PXE...),
  + the provisioning config (`Cloud-config` / `Ignition`),
  + the assets (All images and binaries needed),
  + and the API (for life cycle management).

And the `mayuctl` utility.

> Notes
> --
>
> The DHCP, PXE and TFTP capabilities are in facts provided by an embedded `dnsmasq` instance.
> Its configuration is managed by the `mayu`.
>
> Mayu does not "replace" the provisioning and installing instructions. **It uses the classic CoreOS** tools like `ignition` and `cloud-config`
>

#### Structure

```
├── images/                       // Download CoreOS Images
|
├── static_html/
│   ├── infopusher*
│   └── mayuctl*
|
├── template_snippets/
│   ├── cloudconfig/
│   └── ignition/
|
├── templates/
|   |
│   ├── dnsmasq_template.conf
│   ├── first_stage_script.sh       // Where some magic comes from :)
|   |
│   ├── ignition/
│   ├── first_stage_cloudconfig.yaml
│   └── last_stage_cloudconfig.yaml
|
├── tftproot/
│   └── undionly.kpxe
|
├── config.yaml                 // Config
├── fetch-coreos-image*         // Helper script
├── fetch-coreos-qemu-image*    // Helper script
├── fetch-yochu-assets*         // Helper script
|
├── mayu*                       // The service
└── mayuctl*                    // The client
```

#### Cluster configuration / boot process

Mayu comes in a post-VM era, where we are used to **"comodity" and "standardised" hardware** (aka. same servers).

The idea for "cluster" management is:
* 1. 1 server PXE boots
* 2. The `first_stage_script.sh` runs in the diskless Linux image
* 3. The scripts collects data and calls `mayu` HTTP service to get a provisioning configuration
* 4. `mayu` renders the configuration according to the parameters provided by the call (Renders the templates and **assigns a "profile"**)
* 5. The server reboots once again with `ignition` (or `cloud-config`)

More details here (with pictures :) https://github.com/giantswarm/mayu/blob/master/docs/inside.md


The key concept here is the [**"profile"**](https://github.com/giantswarm/mayu/blob/master/docs/configuration.md#profiles), wich is defined in `mayu` configuration file.
* Profiles have a predefined **quantity** and *tags*
* When a new node boots,
  - if a cluster is not full yet, it will be assign to this one
  - Otherwise, it goes to a `default` one (Usefull for "discovery" when new servers are racked by hosting providers)



### Step by Step bootstrapping

#### A - Start `Mayu`

* Start a Shell and explore
* Start the service
* Check the service

#### B - Boot the VMs

* Check the status
* Check the audit log
* Check the results

#### C - Lifecycle with `mayuctl`

* Add metadata
* Reboot the machine





## 3 - CoreOS Update-engine usage and management








