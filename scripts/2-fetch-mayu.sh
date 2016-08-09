#!/bin/sh

set -e
set -u

: ${1?"Usage: $0 <mayu-version>"}

# Variables
MAYU_VERSION=$1
MAYU_ARTIFACT=mayu.${MAYU_VERSION}-linux-amd64.tar.gz
MAYU_URL="https://github.com/giantswarm/mayu/releases/download/${MAYU_VERSION}/${MAYU_ARTIFACT}"

ABSOLUTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(cd ${ABSOLUTE_DIR}/.. && pwd -P)"
MAYU_DIR=${ROOT_DIR}/giantswarm-mayu
ARTIFACT_DIR=${MAYU_DIR}/${MAYU_ARTIFACT%.tar.gz}


# Create dir
mkdir -vp ${ARTIFACT_DIR}

# remove old images
rm -vrf ${ARTIFACT_DIR}*

# Fetch Mayu
pushd ${MAYU_DIR}
wget -O ${MAYU_ARTIFACT} ${MAYU_URL}
mkdir -vp ${ARTIFACT_DIR}
tar zxf ${MAYU_ARTIFACT} -C ${ARTIFACT_DIR}
popd ${MAYU_DIR}

echo "DONE"
