#!/bin/bash

docker run -it \
  --cap-add=NET_ADMIN \
  --net=host \
  --name=mayu \
  -v $(pwd)/clusters:/var/lib/mayu \
  -v $(pwd)/images:/usr/lib/mayu/images \
  -v $(pwd)/yochu:/usr/lib/mayu/yochu \
  -v $(pwd)/template_snippets:/usr/lib/mayu/template_snippets \
  -v $(pwd)/templates:/usr/lib/mayu/templates \
  -v $(pwd)/conf/config.yaml:/etc/mayu/config.yaml \
  -v /etc/hosts:/etc/hosts \
  -v /etc/resolv.conf:/etc/resolv.conf \
  giantswarm/mayu \
  --no-tls 
