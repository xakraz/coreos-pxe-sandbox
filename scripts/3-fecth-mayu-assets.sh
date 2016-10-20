#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config


# Check COREOS_VERSION
@test "Check CoreOS version (${COREOS_URL})" {
  coreos_version_available="$(
    curl -o /dev/null --silent --head --write-out '%{http_code}\n' \
    ${COREOS_URL}
  )"
  [ "${coreos_version_available}" -ne 404 ]
}

# Copying Mayu scripts
@test "Copying Mayu scripts to Mayu conf dir ${MAYU_CONF_DIR}" {
  cp ${ARTIFACT_DIR}/fetch-coreos-image ${MAYU_CONF_DIR}/
}

# Fetch Mayu
@test "Fetching CoreOS Image: ${COREOS_VERSION}" {
  pushd ${MAYU_CONF_DIR}
  ./fetch-coreos-image ${COREOS_VERSION}
  popd
}

# Tempaltes
@test "Set CoreOS version in config file: ${MAYU_CONF_DIR}/conf/config.yaml" {
  sed -i "s/PH_COREOS_VERSION/${COREOS_VERSION}/" ${MAYU_CONF_DIR}/conf/config.yaml
}


