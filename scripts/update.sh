#!/usr/bin/env bash

export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CURRENT_DIR/helper.sh

check_env_variables
dockerhub_login

remove_compose_containers
remove_dynamic_containers

rm -rf /tmp/.skale
cp -r $CONFIG_DIR /tmp/.skale
rm -rf $CONFIG_DIR

mkdir -p $CONFIG_DIR
copy_node_configs

download_contracts

docker-compose -f $CONFIG_DIR/docker-compose.yml pull
docker-compose -f $CONFIG_DIR/docker-compose.yml up -d

