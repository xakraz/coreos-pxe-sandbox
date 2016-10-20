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
@test "" {
  cp ${ARTIFACT_DIR}/fetch-coreos-image ${CONF_DIR}/
}

# Fetch Mayu
@test "Fetching CoreOS Image: ${COREOS_VERSION}" {
  pushd ${CONF_DIR}
  ./fetch-coreos-image ${COREOS_VERSION}
  popd
}


