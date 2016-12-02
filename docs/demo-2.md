# demo-2.md

<!-- MarkdownTOC depth=5 -->

- [2 - Cluster Bootstrapping with Mayu](#2---cluster-bootstrapping-with-mayu)
  - [What is Mayu ?](#what-is-mayu-)
  - [Mayu config overview](#mayu-config-overview)
    - [A - Features](#a---features)
    - [B - Directory layout](#b---directory-layout)
    - [C - Boot process](#c---boot-process)
  - [Cluster configuration](#cluster-configuration)
  - [Step by Step bootstrapping](#step-by-step-bootstrapping)
    - [A - Prepare `Mayu`](#a---prepare-mayu)
    - [B - Start `Mayu`](#b---start-mayu)
    - [C - Boot the VMs in PXE](#c---boot-the-vms-in-pxe)
    - [D - Lifecycle with `mayuctl`](#d---lifecycle-with-mayuctl)

<!-- /MarkdownTOC -->


### 2 - Cluster Bootstrapping with Mayu

#### What is Mayu ?

There are several ways to setup a **PXE boot environment** and it is different in every company.

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

##### A - Features

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
> Mayu **does not "replace" the provisioning** and installing instructions. **It uses the classic CoreOS** tools like `ignition` and `cloud-config`
>

##### B - Directory layout

```
├── images/                       // Downloaded CoreOS Images
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
│   ├── dnsmasq_template.conf       // Mayu network config
|   |
│   ├── first_stage_script.sh       // Where some magic comes from :)
|   |
│   ├── ignition/                   // CoreOS bootstrap config (Ignition/cloud-config)
│   ├── first_stage_cloudconfig.yaml
│   └── last_stage_cloudconfig.yaml
|
├── tftproot/
│   └── undionly.kpxe
|
├── config.yaml                 // Mayu global config
|
├── fetch-coreos-image*         // Helper script
├── fetch-coreos-qemu-image*    // Helper script
├── fetch-yochu-assets*         // Helper script
|
├── mayu*                       // The service binary
└── mayuctl*                    // The client binary
```

##### C - Boot process

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

> Notes
> --
>
> These steps are now part of the "provisioning" part handled by Vagrant.
> See the [scripts](../scripts/) directory and the [Vagrantfile](../Vagrantfile)
>


##### A - Prepare `Mayu`

[demo-2A](demo-2A.md)

##### B - Start `Mayu`

[demo-2B](demo-2B.md)

##### C - Boot the VMs in PXE

[demo-2C](demo-2C.md)

##### D - Lifecycle with `mayuctl`

[demo-2D](demo-2D.md)
