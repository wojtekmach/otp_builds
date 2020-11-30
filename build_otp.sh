#!/bin/bash

# NOTE: on macOS 11, run as:
#     SYSTEM_VERSION_COMPAT=1 MACOSX_DEPLOYMENT_TARGET=10.16 sh build_otp.sh

if [ $# -ne 3 ]; then
  echo "Usage: sh build_otp.sh REF OUTPUT_TAR_PATH SSL_DIR"
  exit 1
fi

set -ex

REF=$1
OUTPUT_TAR_PATH=$2
SSL_DIR=$3

mkdir -p tmp
cd tmp

if [ ! -f ${REF}_src.tar.gz ]; then
  curl -L -o ${REF}_src.tar.gz https://github.com/erlang/otp/archive/${REF}.tar.gz
fi

tar xzf ${REF}_src.tar.gz
cd otp-${REF}
export ERL_TOP=`pwd`
# NOTE: RELEASE_ROOT must be absolute
export RELEASE_ROOT=`pwd`/${REF}
./otp_build autoconf
./configure --with-ssl=$SSL_DIR --disable-ssl-dynamic-lib
make release -j$(getconf _NPROCESSORS_ONLN)
# TODO: uncomment
# make release_docs DOC_FORMATS="chunks"
tar czf ${OUTPUT_TAR_PATH} ${REF}
