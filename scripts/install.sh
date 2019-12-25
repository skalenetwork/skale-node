#!/usr/bin/env bash
set -e

export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CURRENT_DIR/helper.sh

check_env_variables

create_node_dirs
copy_node_configs
download_contracts
configure_filebeat
configure_flask

if [ -z $DRY_RUN ]; then
    check_disk_mountpoint
    save_partition
    dockerhub_login # todo: remove after containers open-sourcing
    docker-compose -f $CONFIG_DIR/docker-compose.yml build
    docker-compose -f $CONFIG_DIR/docker-compose.yml up -d
fi
