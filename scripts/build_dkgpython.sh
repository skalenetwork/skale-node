#!/bin/bash
set -e

export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CURRENT_DIR/helper.sh

sudo apt-get update
sudo apt-get install -y automake cmake build-essential libprocps-dev libtool\
                        pkg-config yasm texinfo autoconf flex bison python3-distutils.core python3-distutils

cd /tmp
git clone https://github.com/skalenetwork/libBLS.git
cd /tmp/libBLS

cd /tmp/libBLS/deps
./build.sh PARALLEL_COUNT=j$(nproc)
cd /tmp/libBLS

mkdir -p /tmp/libBLS/build
cd /tmp/libBLS/build
cmake /tmp/libBLS/ -DBUILD_WITH_FPIC=ON
if [[ $? -ne 0 ]] ; then
  exit 1
fi

make -j$(nproc) bls
if [[ $? -ne 0 ]] ; then
  exit 1
fi

cd /tmp/libBLS/python/
bash setup.sh
if [[ $? -ne 0 ]] ; then
  exit 1
fi

mv /tmp/libBLS/python/dkgpython.so $NODE_DATA_DIR/dkgpython.so

cd /tmp
rm -rf libBLS
