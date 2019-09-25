# Usage

Install script:

```
sudo -E bash install.sh
```

Install node with custom RPC credentials and use custom contracts:

```bash
RUN_MODE=dev/test/prod RPC_IP=127.0.0.1 RPC_PORT=8546 CUSTOM_CONTRACTS=true sudo -E bash install.sh
```


Uninstall script:

```
sudo -E bash uninstall.sh
```  


Update node software:

```bash
# on machine
cd skale-node
git pull
cd installation
DOCKER_USERNAME=$DOCKER_USERNAME DOCKER_PASSWORD=$DOCKER_PASSWORD RUN_MODE=admin RPC_IP=13.59.228.21 RPC_PORT=1920 \
    CUSTOM_CONTRACTS=true sudo -E bash update.sh
```


Download and run installation script:

```bash
curl -s -L http://skalelabs.com/install.sh | bash
```


Admin container on Docker Hub:
https://hub.docker.com/r/skalelabshub/admin/


### Useful info


Add ENV variables to sudoers:
```
Defaults env_keep += "ENV_VAR1 ENV_VAR2 ..."
```

ENV variables that you will need to set up to run install/uninstall scripts:

```
- PYTHONPATH
- VIRTUAL_ENV
- DOCKER_USERNAME
- DOCKER_PASSWORD
```
