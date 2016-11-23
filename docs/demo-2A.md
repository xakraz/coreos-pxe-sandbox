# A - Prepare `Mayu`

<!-- MarkdownTOC depth=6 -->

- [SSH into `core-provisioner` host](#ssh-into-core-provisioner-host)
- [Fetch Mayu binaries](#fetch-mayu-binaries)
- [Pre-Fetch CoreOS images + other binaries](#pre-fetch-coreos-images--other-binaries)

<!-- /MarkdownTOC -->



###### SSH into `core-provisioner` host

```
$ vagrant ssh core-provisioner

CoreOS alpha (1032.1.0)
Last login: Tue Aug  9 12:02:49 2016 from 10.0.2.2
core@prov ~ $
```

######  Fetch Mayu binaries

```
core@prov ~ $ scripts/2-fetch-mayu.sh
...
mkdir: created directory '/home/core/giantswarm-mayu/mayu.0.11.1-linux-amd64'
~/giantswarm-mayu
DONE
```

######  Pre-Fetch CoreOS images + other binaries

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
