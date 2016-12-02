# CoreRoller introduction

<!-- MarkdownTOC depth=6 -->

- [A - CoreRoller introduction](#a---coreroller-introduction)
  - [Introduction](#introduction)
  - [Concepts](#concepts)
  - [Features](#features)
  - [Example](#example)
    - [a - Start CoreRoller](#a---start-coreroller)
    - [b - Create a "package"](#b---create-a-package)
      - [WebUI](#webui)
      - [HTTP REST API](#http-rest-api)
    - [c - Create a "Group"](#c---create-a-group)

<!-- /MarkdownTOC -->


### A - CoreRoller introduction

#### Introduction

[CoreRoller](https://github.com/coreroller/coreroller) is a set of tools to **control and monitor the rollout of your updates**.

It's aimed to be an open source alternative to CoreOS [CoreUpdate](https://coreos.com/products/coreupdate/).


#### Concepts

The key concepts of the update management are:
* Define _a software package_ with a version
* Define on which _release channel_ it applies
* Create _group of machines_

To define an update, assign 1 group to 1 release channel.

You can _promote_ OR _blacklist_ a package from a specific release.


#### Features

* Dashboard to control and monitor your applications updates
* Manage updates for your own applications, not just for CoreOS
* Define your own groups and channels, even for the CoreOS application (pre-installed)
* Define roll-out policies per group, controlling how updates should be applied to a set of instances
* Pause/resume updates at any time at the group level
* Statistics about versions installed in your instances, updates progress status, etc
* Activity stream to get notified about important events or errors
* Manage updates for your CoreOS clusters out of the box
* HTTP Restful APIs
* Based on the Omaha protocol developed by Google



#### Example

##### a - Start CoreRoller

For this example, we will use the **"demo" docker image** as explained here https://github.com/coreroller/coreroller#getting-started

```
$ vagrant ssh core-provisioner

core@prov ~ $ docker run -d -p 8000:8000 coreroller/demo
```

Once the container is up, just point your browser to: (http://localhost:8000/) (Or the IP of the server where CoreRoller is running)

```
core@prov ~ $ ip addr show

...
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:b3:7a:d1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.2/24 brd 192.168.2.255 scope global eth1           <----
```

http://192.168.2.2:8000

And you should be ready to go. Default username/password is admin/admin.



##### b - Create a "package"

###### WebUI

![Create a package](../img/CoreRoller/CoreRoller-package-1.png)


###### HTTP REST API

```
shared/coreroller  $ http --auth admin:admin --json POST \
                          http://192.168.2.2:8000/api/apps/e96281a6-d1af-4bde-9a0a-97b76e56dc57/packages < coreos-package_1122.2.0.json

HTTP/1.1 200 OK
Content-Length: 697
Content-Type: text/plain; charset=utf-8
Date: Fri, 02 Dec 2016 10:49:48 GMT
X-Authenticated-Username: admin

{
    "application_id": "e96281a6-d1af-4bde-9a0a-97b76e56dc57",
    "channels_blacklist": null,
    "coreos_action": {
        "chromeos_version": "",
        "created_ts": "2016-12-02T10:49:48.937948Z",
        "deadline": "",
        "disable_payload_backoff": true,
        "event": "postinstall",
        "id": "19b4f745-6e7a-45fe-b027-efc3d1cc2218",
        "is_delta": false,
        "metadata_signature_rsa": "",
        "metadata_size": "",
        "needs_admin": false,
        "sha256": "cSBzKN0c6vKinrH0SdqUZSHlQtCa90vmeKC7p/xk19M="          <----
    },
    "created_ts": "2016-12-02T10:49:48.937948Z",
    "description": null,
    "filename": "update.gz",                                              <----
    "hash": "+ZFmPWzv1OdfmKHaGSojbK5Xj3k=",                               <----
    "id": "81f05e1f-46a1-41fc-90ab-5244c9396b19",
    "size": "212555113",                                                  <----
    "type": 1,
    "url": "https://update.release.core-os.net/amd64-usr/1122.2.0/",      <----
    "version": "1122.2.0"                                                 <----
}
```

=> Record the `Package_ID`



##### c - Create a "Group"


```
shared/coreroller  $ http --auth admin:admin --json POST \
                          http://192.168.2.2:8000/api/apps/e96281a6-d1af-4bde-9a0a-97b76e56dc57/groups < my_group.json

HTTP/1.1 200 OK
Content-Length: 1618
Content-Type: text/plain; charset=utf-8
Date: Fri, 02 Dec 2016 11:01:35 GMT
X-Authenticated-Username: admin

...
```







