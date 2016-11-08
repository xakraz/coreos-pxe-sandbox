#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config


# Check COREOS_VERSION
@test "Check CoreOS version url (${COREOS_URL})" {
  coreos_version_available="$(
    curl -o /dev/null --silent --head --write-out '%{http_code}\n' \
    ${COREOS_URL}
  )"
  [ "${coreos_version_available}" -ne 404 ]
}

# Copying Mayu scripts
@test "Copying 'fetch-coreos-image' scripts to Mayu conf dir ${MAYU_CONF_DIR}" {
  cp ${ARTIFACT_DIR}/fetch-coreos-image ${MAYU_CONF_DIR}/
}

@test "Copying 'fetch-yochu-assets' scripts to Mayu conf dir ${MAYU_CONF_DIR}" {
  cp ${ARTIFACT_DIR}/fetch-yochu-assets ${MAYU_CONF_DIR}/
}

# Fetch CoreOS PXE image
@test "Fetching CoreOS Image: ${COREOS_VERSION}" {
  pushd ${MAYU_CONF_DIR}
  ./fetch-coreos-image ${COREOS_VERSION}
  popd
}

# Fetch Yochu assets
@test "Fetching Yochu assets" {
  pushd ${MAYU_CONF_DIR}
  ./fetch-yochu-assets
  popd
}

# Update configfile
@test "Set CoreOS version in config file: ${MAYU_CONF_DIR}/conf/config.yaml" {
  sed -i "s/PH_COREOS_VERSION/${COREOS_VERSION}/" ${MAYU_CONF_DIR}/conf/config.yaml
}

