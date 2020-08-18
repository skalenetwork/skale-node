# SKALE Node

[![Discord](https://img.shields.io/discord/534485763354787851.svg)](https://discord.gg/vvUtWJB)

## An important note about production readiness

SKALE-node is still in active development and therefore should be regarded as alpha software. The development is still subject to security hardening, further testing, and breaking changes. This repository has not yet been reviewed or audited for security.

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

## Contributing

**If you have any questions please ask our development community on [Discord](http://skale.chat).**

[![Discord](https://img.shields.io/discord/534485763354787851.svg)](https://discord.gg/vvUtWJB)

## License

[![License](https://img.shields.io/github/license/skalenetwork/skale-node)](LICENSE)

Copyright (C) 2019-present SKALE Labs
