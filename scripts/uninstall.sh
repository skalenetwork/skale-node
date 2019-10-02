#!/bin/bash

# todo: stop and remove all sChain containers before that (from admin container)

PROJECT_DIR=$(dirname $(pwd))
SKALE_VOL="/skale_vol"
NODE_DATA_DIR="/skale_node_data"

DB_PORT=0 docker-compose -f $SKALE_VOL/config/docker-compose.yml rm  -s -f

rm -rf /skale

rm -rf /tmp/skale_vol
rm -rf /tmp/data_dir
rm -rf /tmp$NODE_DATA_DIR

cp -r /skale_vol /tmp/skale_vol
cp -r $NODE_DATA_DIR /tmp$NODE_DATA_DIR
cp -r /data_dir /tmp/data_dir

rm -rf /data_dir
rm -rf $SKALE_VOL
rm -rf $NODE_DATA_DIR

docker ps -a --format '{{.Names}}' | grep "^skale_schain_" | awk '{print $1}' | xargs -I {} docker rm -f {}
docker ps -a --format '{{.Names}}' | grep "^skale_ima_" | awk '{print $1}' | xargs -I {} docker rm -f {}
