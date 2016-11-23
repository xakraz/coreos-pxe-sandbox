# 2-D - Lifecycle with `mayuctl`


<!-- MarkdownTOC depth=6 -->

- [Git audit](#git-audit)
- [MayuCTL](#mayuctl)

<!-- /MarkdownTOC -->


###### Git audit

In the `clusters` directory shared as a volume:

```
core@prov ~/shared/giantswarm-mayu/mayu.0.11.1-linux-amd64/clusters/ $

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

######  MayuCTL

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

> Notes
> --
>
> More info in Mayu documentation:
> * [Node life cycle management](https://github.com/giantswarm/mayu/blob/master/docs/machine_state_transition.md)
> * [`maycuctl` example](https://github.com/giantswarm/mayu/blob/master/docs/mayuctl.md)
>
