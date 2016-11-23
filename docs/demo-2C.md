# C - Boot the VMs in PXE


<!-- MarkdownTOC depth=6 -->

- [Start the VMs](#start-the-vms)
- [Check the status with `mayuctl`](#check-the-status-with-mayuctl)
- [Access the nodes](#access-the-nodes)

<!-- /MarkdownTOC -->


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


###### Start the VMs

```
$ vagrant up --parallel /core-0/
```


###### Check the status with `mayuctl`

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

Screen-shots of the PXE boot process: [img](../img/)


###### Access the nodes

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
> The Public key has been configured in [`shared/giantswarm-mayu/mayu.0.11.1-linux-amd64/conf/config.yaml`](../shared/giantswarm-mayu/mayu.0.11.1-linux-amd64/conf/config.yaml)
>
> By default, we use Vagrant insecure public key, but you can add your own if you want to.
>

