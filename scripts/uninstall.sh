#!/usr/bin/env bash

export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CURRENT_DIR/helper.sh

remove_compose_containers
remove_dynamic_containers

# todo: stop and remove convoy service
# todo: format disk setted in $NODE_DATA_DIR/disk_mountpoint.txt

rm -rf /tmp/.skale
cp -r $SKALE_DIR /tmp/.skale
rm -rf $SKALE_DIR
