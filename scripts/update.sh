#!/usr/bin/env bash

INSTALLATION_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=$(dirname $INSTALLATION_DIR)
SKALE_VOL="/skale_vol"

if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ] # todo: tmp part
then
    echo "DOCKER_USERNAME or DOCKER_PASSWORD is empty."
    exit 1
else
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
fi


export RUN_MODE=$RUN_MODE
export ENDPOINT=$ENDPOINT
export DB_USER=$DB_USER
export DB_PASSWORD=$DB_PASSWORD
export DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD
export DB_PORT=$DB_PORT
export MTA_ENDPOINT=$MTA_ENDPOINT
export CUSTOM_CONTRACTS=true



TAG=latest docker-compose -f $SKALE_VOL/config/docker-compose.yml rm  -s -f

docker ps -a --format '{{.Names}}' | grep "^skale_schain_" | awk '{print $1}' | xargs -I {} docker rm -f {}
docker ps -a --format '{{.Names}}' | grep "^skale_mta_" | awk '{print $1}' | xargs -I {} docker rm -f {}

rm -rf /tmp/skale_vol
cp -r /skale_vol /tmp/skale_vol
rm -rf $SKALE_VOL

# todo: tmp

mkdir /skale_vol
#mkdir /skale_vol/log
mkdir /skale_vol/config
mkdir /skale_vol/data
mkdir /skale_vol/tools


echo "Copying config folder..."
cp -R $PROJECT_DIR/config/. /skale_vol/config/

echo "Copying tools folder..."
cp -R $PROJECT_DIR/tools/. /skale_vol/tools/


# todo: tmp end!


TAG=latest docker-compose -f $SKALE_VOL/config/docker-compose.yml pull


echo "Run mode: $RUN_MODE"
case $RUN_MODE in
    admin)
          TAG=latest docker-compose -f $SKALE_VOL/config/docker-compose.yml up -d admin
          ;;
     test)
          TAG=latest docker-compose -f $SKALE_VOL/config/docker-compose.yml up admin
          ;;
     dev)
          TAG=latest docker-compose -f $SKALE_VOL/config/docker-compose.yml up #-d
          ;;
     prod)
          TAG=latest docker-compose -f $SKALE_VOL/config/docker-compose.yml up -d
          ;;
     *)
          echo 'Provide valid RUN_MODE option: test/dev/prod'
          ;;
esac
