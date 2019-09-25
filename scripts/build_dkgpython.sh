#!/bin/bash

sudo apt-get update
sudo apt-get install -y automake

git clone https://github.com/skalenetwork/libBLS.git --recursive
cd libBLS
git checkout SKALE-1443-finish-DKG

mkdir -p build
cd build
cmake .. -DBUILD_WITH_FPIC=ON
make -j$(nproc) bls

cd ../python/
bash setup.sh

mv build/lib.linux-x86_64-3.6/dkgpython.cpython-36m-x86_64-linux-gnu.so ../../../tools/bls
mv ../../../tools/bls/dkgpython.cpython-36m-x86_64-linux-gnu.so ../../../tools/bls/dkgpython.so

cd ../../
rm -rf libBLS
