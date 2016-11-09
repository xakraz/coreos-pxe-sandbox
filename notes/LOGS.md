# Logs

<!-- MarkdownTOC -->

- [Overview](#overview)
- [Todo - global](#todo---global)
- [1 - CoreOS Cluster bootsrap](#1---coreos-cluster-bootsrap)
  - [1.0 - Status](#10---status)
  - [1.1 - Warnings](#11---warnings)
  - [1.2 - Notes](#12---notes)
- [2 - `etcd` / `fleet` working out of the box](#2---etcd--fleet-working-out-of-the-box)
  - [2.0 - Status](#20---status)
  - [2.1 - etcd - systemd unit](#21---etcd---systemd-unit)
  - [2.2 - etcdctl](#22---etcdctl)
  - [2.3 - fleetctl](#23---fleetctl)
- [3 - Update-engine](#3---update-engine)
  - [3.0 - Status](#30---status)
  - [3.1 - Omaha server](#31---omaha-server)

<!-- /MarkdownTOC -->


## Overview

1. [x] CoreOS Cluster bootsrap
2. [x] `etcd` / `fleet` working out of the box
3. [ ] Update-engine




## Todo - global

- [x] Yochu assets
- [x] tags commits
- [ ] split the huge README in sub-files





## 1 - CoreOS Cluster bootsrap

### 1.0 - Status

1. [x] Demo workspace bootstrap
2. [x] CoreOS Cluster bootsrap
3. [x] Works in "TL;DR" mode out of the box


### 1.1 - Warnings

#### Warn01

> Ignition setup does not work out the box
> - HARD disk partitioning issue
>
> -> Rollback Mayu config to NOT use ignition...
>


### 1.2 - Notes

#### Note01

> only 2 units are failing when 1st boot:

```
Failed Units: 2
  rkt-gc.service
  update-engine.service
```





## 2 - `etcd` / `fleet` working out of the box

### 2.0 - Status

1. [x] `etcd` systemd unit is running ok
2. [x] `etcdctl` shows a cluster
3. [x] `fleetctl` shows a cluster


### 2.1 - etcd - systemd unit

```
core@core-03 ~ $ systemctl status etcd2.service
● etcd2.service - etcd2
   Loaded: loaded (/etc/systemd/system/etcd2.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/system/etcd2.service.d
           └─20-cloudinit.conf
   Active: active (running) since Tue 2016-11-08 15:18:20 UTC; 18min ago
 Main PID: 1271 (etcd2)
    Tasks: 7
   CGroup: /system.slice/etcd2.service
           └─1271 /usr/bin/etcd2

Nov 08 15:18:22 core-03 etcd2[1271]: added member 34bc8c8d5355398a [http://192.168.2.22:238
Nov 08 15:18:22 core-03 etcd2[1271]: added local member 69e19e695e753e82 [http://192.168.2.
Nov 08 15:18:22 core-03 etcd2[1271]: added member 8206764bd48b65e2 [http://192.168.2.21:238
Nov 08 15:18:22 core-03 etcd2[1271]: the connection with 34bc8c8d5355398a became active
Nov 08 15:18:22 core-03 etcd2[1271]: 69e19e695e753e82 [term: 1] received a MsgVote message
Nov 08 15:18:22 core-03 etcd2[1271]: 69e19e695e753e82 became follower at term 2
Nov 08 15:18:22 core-03 etcd2[1271]: 69e19e695e753e82 [logterm: 1, index: 3, vote: 0] voted
Nov 08 15:18:22 core-03 etcd2[1271]: raft.node: 69e19e695e753e82 elected leader 34bc8c8d535
Nov 08 15:18:22 core-03 etcd2[1271]: published {Name:00002addeb226e2c4365a1ce0cb3f560 Clien
Nov 08 15:18:22 core-03 etcd2[1271]: set the initial cluster version to 2.2
```

=> OK


### 2.2 - etcdctl

#### Note01

```
core@core-01 ~ $ etcdctl cluster-health
member 34bc8c8d5355398a is healthy: got healthy result from http://192.168.2.22:2379
member 69e19e695e753e82 is healthy: got healthy result from http://192.168.2.23:2379
member 8206764bd48b65e2 is healthy: got healthy result from http://192.168.2.21:2379
```

=> OK


### 2.3 - fleetctl

#### Note01

```
core@core-01 ~ $ fleetctl list-machines
MACHINE   IP    METADATA
0000245f... 192.168.2.22  role-core=true
00002add... 192.168.2.23  role-core=true
0000cfb6... 192.168.2.21  role-core=true
```

=> OK





## 3 - Update-engine

### 3.0 - Status

1. [ ] Omaha server
2. [ ] Locksmith configuration
3. [ ] update-engine configuration
4. [ ] Update - CLI validation
5. [ ] Update - GUI validation


### 3.1 - Omaha server

#### Note01

2 Omaha server implementations:
- https://github.com/Crystalnix/omaha-server
- https://github.com/coreroller/coreroller

Docker images:
- https://hub.docker.com/r/crystalnix/omaha-server/tags/
- https://hub.docker.com/u/coreroller/


#### Issue01

https://github.com/Crystalnix/omaha-server/issues/233

>
> Can not make it work ....
>


#### Issue02

https://github.com/coreroller/coreroller/issues/30

>
> Little WebUI glitch
>








