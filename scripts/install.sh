#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=$(dirname $DIR)

SKALE_VOL="/skale_vol"
NODE_DATA_DIR="/skale_node_data"


: "${DISK_MOUNTPOINT?Need to set DISK_MOUNTPOINT}"
: "${ENDPOINT?Need to set ENDPOINT}"
: "${IMA_ENDPOINT?Need to set IMA_ENDPOINT}"

: "${DB_USER?Need to set DB_USER}"
: "${DB_PORT?Need to set DB_PORT}"
: "${DB_PASSWORD?Need to set DB_PASSWORD}"
: "${DB_ROOT_PASSWORD?Need to set DB_ROOT_PASSWORD}"

: "${MANAGER_CONTRACTS_INFO_URL?Need to set MANAGER_CONTRACTS_INFO_URL}"
: "${IMA_CONTRACTS_INFO_URL?Need to set IMA_CONTRACTS_INFO_URL}"
: "${DKG_CONTRACTS_INFO_URL?Need to set DKG_CONTRACTS_INFO_URL}"

: "${DOCKER_USERNAME?Need to set DOCKER_USERNAME}" # todo: remove after containers open-sourcing
: "${DOCKER_PASSWORD?Need to set DOCKER_PASSWORD}" # todo: remove after containers open-sourcing

echo "$DOCKER_PASSWORD" | docker login --username $DOCKER_USERNAME --password-stdin # todo: remove after containers open-sourcing

echo "Creating subdirectories in  $SKALE_VOL and $NODE_DATA_DIR..."
mkdir -p $SKALE_VOL/{config,data,tools,contracts_info}
mkdir -p $NODE_DATA_DIR/{schains,log,ssl}

echo "Copying config folder..."
cp -R $PROJECT_DIR/. /skale_vol/config/

curl -L $MANAGER_CONTRACTS_INFO_URL >  $SKALE_VOL/contracts_info/manager.json
curl -L $IMA_CONTRACTS_INFO_URL >  $SKALE_VOL/contracts_info/ima.json
curl -L $DKG_CONTRACTS_INFO_URL >  $SKALE_VOL/contracts_info/dkg.json


FLASK_SECRET_KEY_FILE=$NODE_DATA_DIR/flask_db_key.txt
if [ -e $FLASK_SECRET_KEY_FILE ]; then
  echo "File $FLASK_SECRET_KEY_FILE already exists!"
else
  FLASK_SECRET_KEY=$(openssl rand -base64 32)
  echo $FLASK_SECRET_KEY >> $FLASK_SECRET_KEY_FILE
fi
export FLASK_SECRET_KEY=$FLASK_SECRET_KEY

DISK_MOUNTPOINT_FILE=$NODE_DATA_DIR/disk_mountpoint.txt
echo $DISK_MOUNTPOINT >> $DISK_MOUNTPOINT_FILE


docker-compose -f $SKALE_VOL/config/docker-compose.yml up -d