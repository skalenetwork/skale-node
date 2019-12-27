#!/usr/bin/env bash
set -e

export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CURRENT_DIR/helper.sh

check_env_variables
docker_lvmpy_install
create_node_dirs
copy_node_configs
download_contracts
configure_filebeat
configure_flask
generate_csr

if [ -z $DRY_RUN ]; then
    check_disk_mountpoint
    save_partition
    dockerhub_login # todo: remove after containers open-sourcing
    docker-compose -f $CONFIG_DIR/docker-compose.yml up -d
fi