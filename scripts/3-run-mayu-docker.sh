#!/bin/bash

## Fail fast
set -e
set -u


## Config
# https://hub.docker.com/r/giantswarm/mayu/tags/
MAYU_VERSION=${MAYU_VERSION:-0.11.1}
MAYU_IMAGE=giantswarm/mayu:${MAYU_VERSION}

MAYU_CONF=/home/core/share/giantswarm-mayu/mayu.${MAYU_VERSION}-linux-amd64
MAYU_DATA=/home/core/giantswarm-mayu/mayu.${MAYU_VERSION}-linux-amd64


# Checks
if [ "$(id -u)" != "0"  ]; then
  echo "This script use 'docker' 'NET_ADMIN' capabilities" 1>&2
  echo "It must be run as root" 1>&2
  exit 1
fi

if [ ! -d "${MAYU_DATA}" ]; then
  echo "ERROR: Directory ${MAYU_DATA} is missing" 1>&2
  echo "ERROR: It is needed as a mounted volume into the container" 1>&2
  exit 1
fi

if [ ! -d "${MAYU_CONF}" ]; then
  echo "ERROR: Directory ${MAYU_CONF} is missing" 1>&2
  echo "ERROR: It is needed as a mounted volume into the container" 1>&2
  exit 1
fi


## Run
docker run -d \
  --cap-add=NET_ADMIN \
  --net=host \
  --name=mayu \
  -v ${MAYU_DATA}/images:/usr/lib/mayu/images \
  -v ${MAYU_DATA}/yochu:/usr/lib/mayu/yochu \
  -v ${MAYU_CONF}/clusters:/var/lib/mayu \
  -v ${MAYU_CONF}/template_snippets:/usr/lib/mayu/template_snippets \
  -v ${MAYU_CONF}/templates:/usr/lib/mayu/templates \
  -v ${MAYU_CONF}/conf/config.yaml:/etc/mayu/config.yaml \
  -v /etc/resolv.conf:/etc/resolv.conf \
  ${MAYU_IMAGE}
  --no-tls \
  --debug \
  --use-internal-etcd-discovery=false --etcd-discovery=https://discovery.etcd.io \
  --use-ignition \
  --cluster-directory /var/lib/mayu/clusters/

