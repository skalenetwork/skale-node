#!/usr/bin/env bash

export SERVICE_NAME=convoy.service
export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CURRENT_DIR/helper.sh

remove_compose_containers
remove_dynamic_containers_full

DISK_MOUNTPOINT=$(cat $DISK_MOUNTPOINT_FILE)
sfdisk --delete $DISK_MOUNTPOINT # todo: this doesn't remove all partitions

rm -rf /tmp/.skale
cp -r $SKALE_DIR /tmp/.skale
rm -rf $SKALE_DIR

systemctl stop $SERVICE_NAME
systemctl disable $SERVICE_NAME
rm /etc/systemd/system/$SERVICE_NAME

systemctl daemon-reload
systemctl reset-failed