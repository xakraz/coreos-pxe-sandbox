#!/usr/bin/env bats
# vim: ft=sh:sw=2:et


# Variables
load config

@test "Preparing mayu FS layout: ${ARTIFACT_DIR}" {

  rm -vrf ${ARTIFACT_DIR}*
  mkdir -vp ${ARTIFACT_DIR}
}

# Fetch Mayu
@test "Fetching mayu ${MAYU_VERSION} from ${MAYU_URL}" {
  pushd ${MAYU_DIR}
  wget --output-document ${MAYU_ARTIFACT} --no-check-certificate ${MAYU_URL}
  mkdir -vp ${ARTIFACT_DIR}
  tar zxf ${MAYU_ARTIFACT} -C ${ARTIFACT_DIR}
  popd
}
