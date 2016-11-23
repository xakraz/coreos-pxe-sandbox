# CoreOS configuration

<!-- MarkdownTOC depth=6 -->

- [A - Locksmith](#a---locksmith)
- [B - Update-engine](#b---update-engine)
- [C - Start the systemd units](#c---start-the-systemd-units)

<!-- /MarkdownTOC -->


Official configuration reference:
- https://coreos.com/os/docs/latest/update-strategies.html


###### A - Locksmith

```
/etc/coreos/update.conf
--

REBOOT_STRATEGY=etcd-lock
LOCKSMITHD_REBOOT_WINDOW_START=14:00
LOCKSMITHD_REBOOT_WINDOW_LENGTH=1h

```


####### Note01

Watch the `etcd-lock` structure

```
core@prov ~ $ etcdctl --endpoints http://192.168.2.21:2379,http://192.168.2.21:4001 \
                      ls --recursive /coreos.com/updateengine

/coreos.com/updateengine/rebootlock
/coreos.com/updateengine/rebootlock/semaphore
```

```
$ etcdctl --endpoints http://192.168.2.21:2379,http://192.168.2.21:4001 get /coreos.com/updateengine/rebootlock/semaphore
{"semaphore":1,"max":1,"holders":null}
```



###### B - Update-engine

https://github.com/coreroller/coreroller#existing-machines

```
/etc/coreos/update.conf
--

GROUP=stable
SERVER=http://192.168.2.2:8000/v1/update/   <----

```



###### C - Start the systemd units

Activate `locksmithd`, deactivated by Cloud-config:

```
sudo systemctl unmask locksmithd.service
sudo systemctl unmask --runtime locksmithd.service
sudo systemctl start locksmithd.service
```


Activate `update-engine`, deactivated by Cloud-config:

```
sudo systemctl unmask update-engine.service
sudo systemctl start update-engine.service

sudo journalctl -f -u update-engine.service
```


