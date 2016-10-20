# Config variables for BATS
#
# Mayu Github
MAYU_VERSION=0.11.1
MAYU_ARTIFACT=mayu.${MAYU_VERSION}-linux-amd64.tar.gz
MAYU_URL="https://github.com/giantswarm/mayu/releases/download/${MAYU_VERSION}/${MAYU_ARTIFACT}"

# CoreOS PXE Assets
COREOS_VERSION=1122.2.0
# This URL is defined in Mayu scripts and they are the source of truth
COREOS_URL="http://stable.release.core-os.net/amd64-usr/${COREOS_VERSION}"

# Project info
PROJECT_DIR="$(cd .. && pwd -P)"
DOWNLOAD_DIR=${PROJECT_DIR}/giantswarm-mayu
ARTIFACT_DIR=${DOWNLOAD_DIR}/${MAYU_ARTIFACT%.tar.gz}
# This dir is part of our project and contains our own configfiles
MAYU_CONF_DIR=${PROJECT_DIR}/shared/giantswarm-mayu/${MAYU_ARTIFACT%.tar.gz}

# Run
MAYU_IMAGE=giantswarm/mayu:${MAYU_VERSION}
MAYU_RUN_OPTIONS="--no-tls \
--debug \
--use-internal-etcd-discovery=false --etcd-discovery=https://discovery.etcd.io \
--use-ignition \
--cluster-directory /var/lib/mayu/clusters/"

