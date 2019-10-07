#!/bin/bash

NODE_DATA_DIR="/skale_node_data"

sudo apt-get update
sudo apt-get install -y automake libboost-all-dev

cd /tmp
git clone https://github.com/skalenetwork/libBLS.git --recursive

git clone git@github.com:boostorg/boost.git --recursive
cd boost
./bootstrap.sh
./b2 link=static threading=multi runtime-link=static stage
./b2 link=static threading=multi runtime-link=static install

cd /tmp/libBLS

mkdir -p build
cd build
cmake .. -DBUILD_WITH_FPIC=ON
if [[ $? -ne 0 ]] ; then
  exit 1
fi

make -j$(nproc) bls
if [[ $? -ne 0 ]] ; then
  exit 1
fi

cd ../python/
bash setup.sh
if [[ $? -ne 0 ]] ; then
  exit 1
fi

mv build/lib.linux-x86_64-3.6/dkgpython.cpython-36m-x86_64-linux-gnu.so $NODE_DATA_DIR/dkgpython.so

cd /tmp
rm -rf libBLS
