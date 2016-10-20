#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config


# Check COREOS_VERSION
@test "Start Mayu as a docker container" {
  sudo docker run -d \
  --cap-add=NET_ADMIN \
  --net=host \
  --name=mayu \
  -v ${MAYU_CONF_DIR}/images:/usr/lib/mayu/images \
  -v ${MAYU_CONF_DIR}/yochu:/usr/lib/mayu/yochu \
  -v ${MAYU_CONF_DIR}/clusters:/var/lib/mayu \
  -v ${MAYU_CONF_DIR}/template_snippets:/usr/lib/mayu/template_snippets \
  -v ${MAYU_CONF_DIR}/templates:/usr/lib/mayu/templates \
  -v ${MAYU_CONF_DIR}/conf/config.yaml:/etc/mayu/config.yaml:ro \
  -v /etc/resolv.conf:/etc/resolv.conf \
  ${MAYU_IMAGE} \
  ${MAYU_RUN_OPTIONS}
}

