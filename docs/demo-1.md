# demo-1


<!-- MarkdownTOC depth=4 -->

- [1 - Up the sandbox environment](#1---up-the-sandbox-environment)
  - [git](#git)
  - [Status](#status)
  - [vagrant up](#vagrant-up)
  - [Description](#description)

<!-- /MarkdownTOC -->


### 1 - Up the sandbox environment

#### git

Before starting, checkout the submodules needed for provisioning the VMs:

```
$ git submodule init
$ git submodule update
```


#### Status

Let's have a quick overlook of the VMs that Vagrant will create:

```
$ vagrant status
Current machine states:

core-provisioner          not created (virtualbox)
core-01                   not created (virtualbox)
core-02                   not created (virtualbox)
core-03                   not created (virtualbox)
```


#### vagrant up

First, UP the provisioner host

```
$ vagrant up core-provisioner
```


#### Description

What it does, described in the Vagrantfile, is:

1. Get the **Vagrant box** from CoreOS.com
2. Disable some features from VBox (since CoreOS is not a regular distro)
3. Sends the ["Provisioning" scripts](../scripts/) to the VM
4. Sync the "shared" resources to the `core-provisioner`
5. Run the provisioning scripts
  - Install [BATS](https://github.com/sstephenson/bats) testing framework (For a nicer output)
  - Activate `IP_FORWARDING` and comfigure `IPTABLES`
  - Downloads the **Mayu assets**
  - Start a **Mayu instance** in a priviledged container



> Note:
> --
>
> We are using RSYNC for file sharing since NFS is not enabled by default on CoreOS.
> - https://www.vagrantup.com/docs/cli/rsync.html
> - https://www.vagrantup.com/docs/cli/rsync-auto.html
>
> But you can use it if you wish to use a CoreOS Box as you development environment :)
> - https://coreos.com/os/docs/latest/booting-on-vagrant.html#shared-folder-setup
>

