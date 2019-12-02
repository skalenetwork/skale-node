#!/usr/bin/env bash
set -e

export CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CURRENT_DIR/helper.sh

check_env_variables
check_disk_mountpoint
dockerhub_login # todo: remove after containers open-sourcing

echo "Creating SKALE node directories..."
mkdir -p $SKALE_DIR/{node_data,contracts_info,config}
mkdir -p $SKALE_DIR/node_data/{schains,log,ssl}

copy_node_configs
download_contracts

cp $PROJECT_DIR/filebeat.yml $NODE_DATA_DIR/

if [ -e $FLASK_SECRET_KEY_FILE ]; then
  echo "File $FLASK_SECRET_KEY_FILE already exists!"
else
  FLASK_SECRET_KEY=$(openssl rand -base64 32)
  echo $FLASK_SECRET_KEY >> $FLASK_SECRET_KEY_FILE
fi
export FLASK_SECRET_KEY=$FLASK_SECRET_KEY

echo $DISK_MOUNTPOINT >> $DISK_MOUNTPOINT_FILE

docker-compose -f $CONFIG_DIR/docker-compose.yml up -d