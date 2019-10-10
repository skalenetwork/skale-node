#!/bin/bash

NODE_DATA_DIR="/skale_node_data"

sudo apt-get update
sudo apt-get install -y automake cmake libboost-all-dev build-essential libprocps-dev\
                        libgmp3-dev libssl-dev pkg-config\

cd /tmp
git clone https://github.com/skalenetwork/libBLS.git --recursive

cd /tmp/libBLS

mkdir -p /tmp/libBLS/build
cd /tmp/libBLS/build
cmake /tmp/libBLS/ -DBUILD_WITH_FPIC=ON
if [[ $? -ne 0 ]] ; then
  exit 1
fi
x
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
