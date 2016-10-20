coreos-pxe-sandbox
--

<!-- MarkdownTOC -->

- [TL;DR](#tldr)
- [Overview](#overview)
- [Description](#description)
  - [VBox topology](#vbox-topology)
  - [Requirements](#requirements)
- [Demos](#demos)
  - [1 - Up the sandbox environment](#1---up-the-sandbox-environment)
  - [2 - Cluster Bootstrapping with Mayu](#2---cluster-bootstrapping-with-mayu)
  - [3 - CoreOS Update-engine usage and management](#3---coreos-update-engine-usage-and-management)

<!-- /MarkdownTOC -->


## TL;DR

```
```

## Overview

This repo contains a Vagrant setup to experiment **cluster provisioning** of [CoreOS](https://coreos.com/) instances with [Mayu](https://github.com/giantswarm/mayu/), a tool provided by [GiantSwam](https://giantswarm.io/products/).

The goal is to have a "sandbox" environment where it is easy to try and test **bootstrapping on Baremetal**, the automated way (As you may need in a company).


[CoreOS Paris UG Meetup slides](20160719_CoreOS_1-cluster-bootstrapping.pdf)


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

Before starting, checkout the submodules needed for provisioning the VMs:

```
$ git submodule init
$ git submodule update
```

Let's have a quick overlook of the VMs that Vagrant will create:

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
  - Install [BATS](https://github.com/sstephenson/bats) testing framework (For a nicer output)
  - Activate `IP_FORWARDING` and comfigure `IPTABLES`
* And finaly sync the "shared" resources to the `core-provisioner`


> Note:
> --
>
> We are using RSYNC for file sharing since NFS is not enabled by default on CoreOS.
> But you can use it if you wish to use a CoreOS Box as you development environment :)
>



### 2 - Cluster Bootstrapping with Mayu

#### Why Mayu ?

There are several ways to setup a PXE boot environment and it is different in every company.

CoreOS has recently started the [`core-baremetal`](https://github.com/coreos/coreos-baremetal) project that is pretty close to what `mayu` offers.

However `mayu` is really interesting for the following reasons:
- It **can integrate** into an exsiting PXE boot environment (it is an other HTTP service that provides resources after PXE)
- It **can be an "all-in one"** solution when using the container image (Contrary to `coreos-baremetal/bootcfg` which needs the other infrastructure components)
- It has **templating support** for complex and modular configuration file support
- It has an [**audit feature**](https://github.com/giantswarm/mayu/blob/master/docs/running.md) using `Git`
- And a HTTP RestAPI + client [`maycuctl`](https://github.com/giantswarm/mayu/blob/master/docs/mayuctl.md) that allows you to [**manage the life cycle**](https://github.com/giantswarm/mayu/blob/master/docs/machine_state_transition.md) of the servers from the same place


#### Mayu config overview

To run mayu, you can follow the very good documenation from the project repo.
But we will provide a quick overview.

##### Features

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

##### Structure

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

##### Cluster configuration / boot process

Mayu comes in a post-VM era, where we are used to **"comodity" and "standardised" hardware** (aka. same servers).

The idea for "cluster" management is:
* 1. 1 server PXE boots
* 2. The `first_stage_script.sh` runs in the diskless Linux image
* 3. The scripts collects data and calls `mayu` HTTP service to get a provisioning configuration
* 4. `mayu` renders the configuration according to the parameters provided by the call (Renders the templates and **assigns a "profile"**)
* 5. The server reboots once again with `ignition` (or `cloud-config`)

More details here (with pictures :) https://github.com/giantswarm/mayu/blob/master/docs/inside.md

#### Cluster configuration

The key concept here are the [**"profiles"**](https://github.com/giantswarm/mayu/blob/master/docs/configuration.md#profiles), wich are defined in `mayu` configuration file.
* Profiles have a predefined **quantity** and *tags*
* When a new node boots,
  - if a cluster is not full yet, it will be assign to this one
  - Otherwise, it goes to a `default` one (Usefull for "discovery" when new servers are racked by hosting providers)



#### Step by Step bootstrapping

#### A - Prepare `Mayu`

##### SSH into `core-provisioner` host

```
$ vagrant ssh core-provisioner

CoreOS alpha (1032.1.0)
Last login: Tue Aug  9 12:02:49 2016 from 10.0.2.2
core@prov ~ $
```

#####  Fetch Mayu binaries

```
core@prov ~ $ scripts/2-fetch-mayu.sh
...
mkdir: created directory '/home/core/giantswarm-mayu/mayu.0.11.1-linux-amd64'
~/giantswarm-mayu
DONE
```

#####  Pre-Fetch CoreOS images + other binaries

Using the `fetch-coreos-image` utility script provided by `mayu` artifact:

```
core@prov ~ $ cd giantswarm-mayu/mayu.0.11.1-linux-amd64

core@prov ~/giantswarm-mayu/mayu.0.11.1-linux-amd64 $ ./fetch-coreos-image 1068.6.0
...
```

```
core@prov ~ $ cd giantswarm-mayu/mayu.0.11.1-linux-amd64
core@prov ~/giantswarm-mayu/mayu.0.11.1-linux-amd64 $ ./fetch-yochu-assets
...
```

=>

```
core@prov ~/giantswarm-mayu/mayu.0.11.1-linux-amd64 $ ls -l images/1068.6.0/
total 524692
-rw-r--r--. 1 core core         9 Aug  9 13:38 coreos-version
-rw-r--r--. 1 core core 267866943 Jul 12 21:59 coreos_production_image.bin.bz2
-rw-r--r--. 1 core core  33839200 Jul 12 21:59 coreos_production_pxe.vmlinuz
-rw-r--r--. 1 root root 235548737 Aug  9 13:38 coreos_production_pxe_image.cpio.gz
```


#### B - Start `Mayu`

#####  Check the `mayu` conf

Located in the `share` directory
* The default CoreOS Image
* The network setup for Mayu
* The clusters Profiles
* And SSH Keys

```
core@prov ~ $ cat share/giantswarm-mayu/mayu.0.11.1-linux-amd64/conf/config.yaml
```

#####  Start the container and explore

With the provided [script](scripts/3-run-mayu-docker.sh) and the good volumes:

```
core@prov ~ $ sudo scripts/3-run-mayu-docker.sh

Unable to find image 'giantswarm/mayu:0.11.1' locally
0.11.1: Pulling from giantswarm/mayu
...
Status: Downloaded newer image for giantswarm/mayu:0.11.1
19b172678f35e3456a39159c5c3960330d18b0e331cbf719468d48a5c0fdf71f
```

```
core@prov ~ $ docker ps -a
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS               NAMES
19b172678f35        giantswarm/mayu:0.11.1   "mayu --cluster-direc"   3 seconds ago       Up 2 seconds                            mayu
```

You can explore the container with:

```
core@prov ~ $ docker exec -it mayu /bin/bash
root@prov:/usr/lib/mayu#
```

And follow the logs with

```
core@prov ~ $ docker logs -f mayu
E0809 15:07:21.955479       1 dnsmasq.go:75] signal: killed

```

> Note
> --
>
> By default, `Mayu` thinks it can access an ETCD instance running on the same host to enable the `etcd` bootstrapping of the CoreOS clusters.
>
> The documation regarding this is not linked anywhere but is readable there: https://github.com/giantswarm/mayu/blob/master/docs/etcd_clusters.md
>
> For workshop reasons, we will use the public ETCD service provided by CoreOS. But, of course, for production usage, use a local etcd instance as explained.

#####  Check the service

On the `core-provisioner` host, we can see the bindings:

```
$ vagrant ssh core-provisioner

core@prov ~ $ sudo netstat -plntu
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 192.168.2.2:53          0.0.0.0:*               LISTEN      2904/dnsmasq
udp        0      0 192.168.2.2:53          0.0.0.0:*                           2904/dnsmasq
udp        0      0 0.0.0.0:67              0.0.0.0:*                           2904/dnsmasq
udp        0      0 10.0.2.15:68            0.0.0.0:*                           1204/systemd-network  (DHCP Client)
udp        0      0 192.168.2.2:69          0.0.0.0:*                           2904/dnsmasq          (DHCP Server)

tcp6       0      0 :::4080                 :::*                    LISTEN      2890/mayu       (Mayu HTTP Service)

tcp6       0      0 fe80::a00:27ff:fe7c::53 :::*                    LISTEN      2904/dnsmasq
tcp6       0      0 :::22                   :::*                    LISTEN      1/systemd
udp6       0      0 fe80::a00:27ff:fea7:546 :::*                                1204/systemd-networ
udp6       0      0 fe80::a00:27ff:fe7c::53 :::*                                2904/dnsmasq
udp6       0      0 fe80::a00:27ff:fe7c::69 :::*                                2904/dnsmasq
```

And using the client `mayuctl` localy from the fetched artifact:

```
core@prov ~/giantswarm-mayu/mayu.0.11.1-linux-amd64 $ ./mayuctl --no-tls list
IP  SERIAL  PROFILE  IPMIADDR  PROVIDERID  ETCDTOKEN  METADATA  COREOS  STATE  LASTBOOT
```


#### C - Boot the VMs in PXE

> Notes
> --
>
> `mayu` uses the `serial_number` of the servers as a UUID: https://github.com/giantswarm/mayu/blob/master/templates/first_stage_script.sh#L23.
>
> However, by **default VBox does not manage that** and assigns 0 for every VMs.
>
> To trick that, we have to add this option in `Vagrantfile`:
> ```
> vb.customize ["setextradata", :id, "VBoxInternal/Devices/pcbios/0/Config/DmiSystemSerial", "string:#{mac}-#{index}"]
> ```
>
> Links:
> - https://coderwall.com/p/b5mu2w/symlinks-in-shares-for-vagrant
> - http://superuser.com/questions/55561/how-can-i-change-the-bios-serial-number-in-virtualbox
> - http://www.virtualbox.org/manual/ch09.html#changedmi
>

##### Start the VMs

```
$ vagrant up --parallel /core-0/
```

##### Check the status with `mayuctl`

```
Every 5.0s: ./mayuctl --no-tls list                                                                                                                              Tue Aug  9 14:21:49 2016

IP            SERIAL          PROFILE        IPMIADDR  PROVIDERID  ETCDTOKEN                         METADATA        COREOS    STATE         LASTBOOT
192.168.2.21  0800278e158a-0  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installing"  0001-01-01 00:00:00
192.168.2.22  0800278e158b-1  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installing"  0001-01-01 00:00:00
192.168.2.23  0800278e158c-2  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installing"  0001-01-01 00:00:00
```

```
Every 5.0s: ./mayuctl --no-tls list                                                                                                                              Tue Aug  9 14:23:40 2016

IP            SERIAL          PROFILE        IPMIADDR  PROVIDERID  ETCDTOKEN                         METADATA        COREOS    STATE         LASTBOOT
192.168.2.21  0800278e158a-0  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installed"   0001-01-01 00:00:00
192.168.2.22  0800278e158b-1  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installing"  0001-01-01 00:00:00
192.168.2.23  0800278e158c-2  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installing"  0001-01-01 00:00:00
```

```
Every 5.0s: ./mayuctl --no-tls list                                                                                                                              Tue Aug  9 14:29:21 2016

IP            SERIAL          PROFILE        IPMIADDR  PROVIDERID  ETCDTOKEN                         METADATA        COREOS    STATE        LASTBOOT
192.168.2.21  0800278e158a-0  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installed"  0001-01-01 00:00:00
192.168.2.22  0800278e158b-1  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installed"  0001-01-01 00:00:00
192.168.2.23  0800278e158c-2  core-services  -         -           41f07d10ab835b22071a32d5c1b75a6d  role-core=true  1068.6.0  "installed"  0001-01-01 00:00:00
```

```
Every 5.0s: giantswarm-mayu/mayu.0.11.1-linux-amd64/mayuctl --no-tls list                                                                                        Tue Aug  9 15:49:18 2016

IP            SERIAL          PROFILE        IPMIADDR  PROVIDERID  ETCDTOKEN                         METADATA        COREOS    STATE      LASTBOOT
192.168.2.21  0800278e158a-0  core-services  -         -           416b381afbc752dfc77e48ba7a99ccc3  role-core=true  1068.6.0  "running"  2016-08-09 15:49:02
192.168.2.22  0800278e158b-1  core-services  -         -           416b381afbc752dfc77e48ba7a99ccc3  role-core=true  1068.6.0  "running"  2016-08-09 15:49:06
192.168.2.23  0800278e158c-2  core-services  -         -           416b381afbc752dfc77e48ba7a99ccc3  role-core=true  1068.6.0  "running"  2016-08-09 15:49:11
```

https://github.com/giantswarm/mayu/blob/master/docs/machine_state_transition.md

Screen-shots of the PXE boot process: [img](img/)

##### Access the nodes

From vagrant

```
$ vagrant ssh core-01

CoreOS stable (1068.6.0)
Last login: Tue Aug  9 14:25:44 2016 from 192.168.2.1
Update Strategy: No Reboots
core@core-01 ~ $
```

From our `private_network`

```
$ ssh core@192.168.2.22 -i ~/.vagrant.d/insecure_private_key


CoreOS stable (1068.6.0)
Last login: Tue Aug  9 14:28:04 2016 from 192.168.2.1
Update Strategy: No Reboots
core@core-02 ~ $
```

> Notes
> --
>
> The Public key has been configured in [`share/giantswarm-mayu/mayu.0.11.1-linux-amd64/conf/config.yaml`](share/giantswarm-mayu/mayu.0.11.1-linux-amd64/conf/config.yaml)
>


#### D - Lifecycle with `mayuctl`

##### Git audit

In the `clusters` directory shared as a volume:

```
core@prov ~/share/giantswarm-mayu/mayu.0.11.1-linux-amd64/clusters/clusters $

git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit

* 9a5e1bc - (HEAD -> master) 0800278e158a-0: updated host cabinet (4 minutes ago) <mayu commiter>
* d9bdef6 - 0800278e158c-2: updated state to running (25 minutes ago) <mayu commiter>
* f93d5c1 - 0800278e158b-1: updated state to running (25 minutes ago) <mayu commiter>
* c56d9c3 - 0800278e158a-0: updated state to running (25 minutes ago) <mayu commiter>
* e4e6e61 - 0800278e158c-2: updated state to installed (25 minutes ago) <mayu commiter>
* 07f0c07 - 0800278e158b-1: updated state to installed (26 minutes ago) <mayu commiter>
* 63daf45 - 0800278e158a-0: updated state to installed (26 minutes ago) <mayu commiter>
* bc48a55 - 0800278e158c-2: updated host state to installing (28 minutes ago) <mayu commiter>
* 559b4d3 - 0800278e158c-2: updated host connected nic (28 minutes ago) <mayu commiter>
* 6f350c7 - 0800278e158c-2: collected host mac addresses (28 minutes ago) <mayu commiter>
* 1ed8109 - 0800278e158c-2: set default etcd discovery token (28 minutes ago) <mayu commiter>
* 43f43bf - 0800278e158c-2: updated host profile and metadata (28 minutes ago) <mayu commiter>
* 9088d5d - 0800278e158c-2: updated host InternalAddr (28 minutes ago) <mayu commiter>
* 32f99d0 - 0800278e158c-2: updated with predefined settings (28 minutes ago) <mayu commiter>
* be6372c - 0800278e158c-2: host created (28 minutes ago) <mayu commiter>
* bd6c5c4 - 0800278e158b-1: updated host state to installing (28 minutes ago) <mayu commiter>
* 8ce0505 - 0800278e158b-1: updated host connected nic (28 minutes ago) <mayu commiter>
* 78666bb - 0800278e158b-1: collected host mac addresses (28 minutes ago) <mayu commiter>
* c388ab8 - 0800278e158b-1: set default etcd discovery token (28 minutes ago) <mayu commiter>
* b5bb370 - 0800278e158b-1: updated host profile and metadata (28 minutes ago) <mayu commiter>
* 5771ae2 - 0800278e158b-1: updated host InternalAddr (28 minutes ago) <mayu commiter>
* e9f444c - 0800278e158b-1: updated with predefined settings (28 minutes ago) <mayu commiter>
* 054a668 - 0800278e158b-1: host created (28 minutes ago) <mayu commiter>
* e7a5aff - 0800278e158a-0: updated host state to installing (28 minutes ago) <mayu commiter>
* 8abe427 - 0800278e158a-0: updated host connected nic (28 minutes ago) <mayu commiter>
```

#####  MayuCTL

```
$ ./mayuctl --no-tls status 0800278e158a-0

Serial:              0800278e158a-0
IP:                  192.168.2.21
...
State:               "running"
```

```
$ ./mayuctl --no-tls set 0800278e158a-0 state configured
```

And PXE reboot to reinstall the server.




### 3 - CoreOS Update-engine usage and management








