#!/bin/bash

## Fail fast
set -e
set -u


## Config
MAYU_HOME=/home/core/share/giantswarm-mayu/mayu.0.11.1-linux-amd64


## Run
#docker run -it \
#  --cap-add=NET_ADMIN \
#  --net=host \
#  --name=mayu \
#  -v ${MAYU_HOME}/clusters:/var/lib/mayu \
#  -v ${MAYU_HOME}/images:/usr/lib/mayu/images \
#  -v ${MAYU_HOME}/yochu:/usr/lib/mayu/yochu \
#  -v ${MAYU_HOME}/template_snippets:/usr/lib/mayu/template_snippets \
#  -v ${MAYU_HOME}/templates:/usr/lib/mayu/templates \
#  -v ${MAYU_HOME}/static_html:/usr/lib/mayu/static_html \
#  -v ${MAYU_HOME}/conf/config.yaml:/etc/mayu/config.yaml \
#  -v /etc/hosts:/etc/hosts \
#  -v /etc/resolv.conf:/etc/resolv.conf \
#  giantswarm/mayu \
#  --no-tls --debug --v 12 --use-ignition \
#  --show-templates


docker run -it \
  --cap-add=NET_ADMIN \
  --net=host \
  --name=mayu \
  -v ${MAYU_HOME}/clusters:/var/lib/mayu \
  -v ${MAYU_HOME}/images:/usr/lib/mayu/images \
  -v ${MAYU_HOME}/yochu:/usr/lib/mayu/yochu \
  -v ${MAYU_HOME}/template_snippets:/usr/lib/mayu/template_snippets \
  -v ${MAYU_HOME}/templates:/usr/lib/mayu/templates \
  -v ${MAYU_HOME}/static_html:/usr/lib/mayu/static_html \
  -v ${MAYU_HOME}/conf/config.yaml:/etc/mayu/config.yaml \
  -v /etc/hosts:/etc/hosts \
  -v /etc/resolv.conf:/etc/resolv.conf \
  --entrypoint /bin/bash \
  giantswarm/mayu 
