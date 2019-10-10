#!/usr/bin/env bash

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PROJECT_DIR=$(dirname $DIR)
export SKALE_DIR=~/.skale
export NODE_DATA_DIR=$SKALE_DIR/node_data
export CONFIG_DIR=$SKALE_DIR/config
export FLASK_SECRET_KEY_FILE=$NODE_DATA_DIR/flask_db_key.txt
export DISK_MOUNTPOINT_FILE=$NODE_DATA_DIR/disk_mountpoint.txt

remove_dynamic_containers () {
    docker ps -a --format '{{.Names}}' | grep "^skale_schain_" | awk '{print $1}' | xargs -I {} docker rm -f {}
    docker ps -a --format '{{.Names}}' | grep "^skale_ima_" | awk '{print $1}' | xargs -I {} docker rm -f {}
}

remove_compose_containers () {
   DB_PORT=0 docker-compose -f $SKALE_DIR/config/docker-compose.yml rm  -s -f
}

copy_node_configs () {
    echo "Copying skale-node to config DIR..."
    rsync -r --exclude '.git' $PROJECT_DIR/ $SKALE_DIR/config/
}

download_contracts () {
    curl -L $MANAGER_CONTRACTS_INFO_URL > $SKALE_DIR/contracts_info/manager.json
    curl -L $IMA_CONTRACTS_INFO_URL > $SKALE_DIR/contracts_info/ima.json
}

check_env_variables () {
    : "${ENDPOINT?Need to set ENDPOINT}"
    : "${IMA_ENDPOINT?Need to set IMA_ENDPOINT}"

    : "${DB_USER?Need to set DB_USER}"
    : "${DB_PORT?Need to set DB_PORT}"
    : "${DB_PASSWORD?Need to set DB_PASSWORD}"
    : "${DB_ROOT_PASSWORD?Need to set DB_ROOT_PASSWORD}"

    : "${MANAGER_CONTRACTS_INFO_URL?Need to set MANAGER_CONTRACTS_INFO_URL}"
    : "${IMA_CONTRACTS_INFO_URL?Need to set IMA_CONTRACTS_INFO_URL}"

    : "${DOCKER_USERNAME?Need to set DOCKER_USERNAME}" # todo: remove after containers open-sourcing
    : "${DOCKER_PASSWORD?Need to set DOCKER_PASSWORD}" # todo: remove after containers open-sourcing

    : "${FILEBEAT_HOST?Need to set FILEBEAT_HOST}" # todo: remove later
}

check_disk_mountpoint () {
    : "${DISK_MOUNTPOINT?Need to set DISK_MOUNTPOINT}"
}

dockerhub_login () {
    echo "$DOCKER_PASSWORD" | docker login --username $DOCKER_USERNAME --password-stdin # todo: remove after containers open-sourcing
}