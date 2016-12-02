# demo-3.md

<!-- MarkdownTOC depth=5 -->

- [3 - CoreOS Update-engine usage and management](#3---coreos-update-engine-usage-and-management)
  - [CoreOS update philosophy](#coreos-update-philosophy)
  - [Update components](#update-components)
    - [A - Update-engine](#a---update-engine)
    - [B - Locksmith](#b---locksmith)
  - [Setp by step management](#setp-by-step-management)
    - [A - CoreRoller introduction](#a---coreroller-introduction)
    - [B - CoreOS configuration](#b---coreos-configuration)
    - [C - Update progress follow-up](#c---update-progress-follow-up)

<!-- /MarkdownTOC -->


### 3 - CoreOS Update-engine usage and management

#### CoreOS update philosophy

CoreOS believes _the ability to easily and automatically_ update software **is the most effective way** to improve server security.

To do so, they have implemented the [Omaha update protocol](https://github.com/google/omaha), defined by Google for the Chrome web browser on Windows.
The features provided by this protocol are:
- Atomicity
- Coordination
- Automatic rollback


The disturbing concepts are :
* Updates are **"pushed"**
* Updates are **automatically installed**


Official links from CoreOS:
- https://coreos.com/why/#updates
- https://coreos.com/os/docs/latest/update-strategies.html



#### Update components

##### A - Update-engine

[Update-engine](https://github.com/coreos/update_engine)

The `update-engine` is the program in charge of:
- Downloading the update
- Installing the update
- And asking for a reboot to apply the update

>
> The Omaha protocol has a concept of "coordination" with "canary" servers, update window, ... but the `update-engine` is not in charge of it.
> This task is delegated to the `locksmith` utility tool.
>


##### B - Locksmith

[Locksmith](https://github.com/coreos/locksmith)

>
> locksmith is a reboot manager for the CoreOS update engine which **uses etcd** to ensure that only a subset of a cluster of machines are rebooting at any given time.
> `locksmithd` runs as a daemon on CoreOS machines and is responsible for controlling the reboot behaviour after updates.
>



#### Setp by step management

CoreOS "pushes" the updates... but,
- How can I **control which update is pushed** to my clusters ?
- How can I **control when** the updates are applied ?
- How can I **see and visualize** the state of the nodes ?


##### A - CoreRoller introduction

[demo-3A](demo-3A.md)

##### B - CoreOS configuration

[demo-3B](demo-3B.md)

##### C - Update progress follow-up

[demo-3C](demo-3C.md)