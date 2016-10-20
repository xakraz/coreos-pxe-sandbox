# Config vairables for BATS
#
# Mayu Github
MAYU_VERSION=0.11.1
MAYU_ARTIFACT=mayu.${MAYU_VERSION}-linux-amd64.tar.gz
MAYU_URL="https://github.com/giantswarm/mayu/releases/download/${MAYU_VERSION}/${MAYU_ARTIFACT}"

# CoreOS PXE Assets
COREOS_VERSION=1032.1.0

# Project
PROJECT_DIR="$(cd .. && pwd -P)"
MAYU_DIR=${PROJECT_DIR}/giantswarm-mayu
ARTIFACT_DIR=${MAYU_DIR}/${MAYU_ARTIFACT%.tar.gz}
