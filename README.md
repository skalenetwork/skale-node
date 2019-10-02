# SKALE node

SKALE Node Installation, update and uninstall scripts

## Arguments:

Environment variables needed to execute the installation script

    IMA_ENDPOINT     - IMA endpoint to connect ('http://<IP>:1919')
    ENDPOINT         - RPC endpoint of the node in the network where SKALE Manager is deployed ('ws://<IP>:1920')
    RPC_IP           - RPC IP of the network with SKALE Manager ('<IP>')
    RPC_PORT         - RPC port of the network with SKALE Manager (default is 1920)
    DB_PORT          - Port for of node internal database (default is `3306`)
    DB_USER          - MySQL user for local node database (default is root)
    DB_ROOT_PASSWORD - Password for root user of node internal database (equal to user password by default)

## Scripts

How to execute install, uninstall or update scripts: 

### Installation

```bash
export $(grep -v '^#' .env | xargs) && sudo -E bash ./scripts/install.sh
```

### Uninstall

```bash
export $(grep -v '^#' .env | xargs) && sudo -E bash ./scripts/uninstall.sh
```

### Update

```bash
export $(grep -v '^#' .env | xargs) && sudo -E bash ./scripts/update.sh
```

## Documentation

### Volume

Directories created with the installation script: 

    .
    ├── skale_vol                       # All configuration files and persistent data downloaded from skale_node repository
    │   ├── contracts_info              # Smart contracts needed for IMA, SKALE Manager and DKG
    │   │ 
    │   ├── config                      # Configurations (static) needed for running docker containers
    │   │   ├── containers.json         # Additional containers running on the node
    │   │   ├── proxy.json              # Proxy configuration file used by IMA  
    │   │   ├── docker-compose.yml      # Config that is applied to each container and exposed ports for base container
    │   │   ├── init.sql                # Used by MySQL to create tables for storing SLA reports and bounty data
    │   │   ├── schain_base_config.json # Static part of SKALE chain config file. Generated dynamic part 
    │   │   │                             including all ip addresses and ports will be added to this base config. 
    │   │   │                             Precompiled smart contracts are stored here as well.
    │   │   ├── data.json               # ABIs and addresses
    │   │   └── dkg_contract_data.json  # ABI used for DKG 
    │   │ 
    ├── skale_node_data                       # Runtime info generated with the node executions
    │   ├── schains                           # All SKALE chains (directories) served by the connected node
    │   │   ├── memory                        # This is the dynamic part of the chain
    │   │   │                             Filestorage, smart contract, preallocated(ETH) money
    │   │   ├── <schainname>                  # Directory of one SKALE chain assigned to the node
    │   │   │   └── schain_<schainname>.json  # SKALE chain node information and allocated ports
    │   └── logs                              # Generated base and SKALE chain logs

### SKALE Containers

The following base containers will be created during installation for each node.

    Admin    # Manages all operations in the SKALE node
    MySQL    # Stores bounty, node downtime and latency data  
    SLA      # SKALE Node Monitoring Service (NMS)
    Bounty   # Bounty collector for getting rewards for validator node

Following containers will be created dynamically. These will be created when the registered node is 
assigned randomly to a SKALE chain in the network by SKALE Manager

    IMA     # SKALE Interchain Messaging Agent
    SCHAIN  # SKALE Chain container with SKALED which includes SKALE Consensus
