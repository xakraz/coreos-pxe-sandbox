# B - Start `Mayu`


<!-- MarkdownTOC depth=6 -->

- [Check the `mayu` conf](#check-the-mayu-conf)
- [Start the container and explore](#start-the-container-and-explore)
- [Check the service](#check-the-service)
- [Try `mayuctl`](#try-mayuctl)

<!-- /MarkdownTOC -->




######  Check the `mayu` conf

The config file `config.yaml` is located in the [`shared`](../shared/giantswarm-mayu/) directory.

You will find:
* The default CoreOS Image
* The network setup for Mayu
* The clusters Profiles
* The SSH Keys
* The YOCHU assets and versions (Tools binary)

```
core@prov ~ $ cat shared/giantswarm-mayu/mayu.0.11.1-linux-amd64/conf/config.yaml
```


###### Start the container and explore

With the provided [script](../scripts/4-run-mayu-docker.sh) and the good volumes:

```
core@prov ~ $ sudo scripts/4-run-mayu-docker.sh

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
> By default, `Mayu` thinks it can access an **ETCD instance running on the same host** to enable the `etcd` bootstrapping of the CoreOS clusters.
>
> The documentation regarding this is not linked anywhere but is readable there: https://github.com/giantswarm/mayu/blob/master/docs/etcd_clusters.md
>
> For workshop reasons, we will use the public ETCD service provided by CoreOS (https://discovery.etcd.io). But, of course, for production usage, use a local `etcd` instance as explained.


###### Check the service

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



###### Try `mayuctl`

Try the client `mayuctl` localy from the fetched artifact:

```
core@prov ~/giantswarm-mayu/mayu.0.11.1-linux-amd64 $ ./mayuctl --no-tls list
IP  SERIAL  PROFILE  IPMIADDR  PROVIDERID  ETCDTOKEN  METADATA  COREOS  STATE  LASTBOOT
```
