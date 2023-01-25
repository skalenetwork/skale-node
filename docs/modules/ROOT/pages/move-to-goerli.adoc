= {Network} Move to goerli
include::parameters.adoc[]
:sectnums:
:sectnumlevels: 1

This page is a guide how to connect a testnet node to goerli.

Initially testnet node was connected to test SKALE Network which was connected to Rinkeby, which became outdated in October 2022.
It is a perfect opportunity to combine validators testnet and dapp testnet into one test SKALE Network infrastructure which connected to Goerli.

Node requirements for validators:
 - Please follow this guide to move your testnet node to test SKALE Network infrastructure which connected to Goerli
 - Run only ONE node(if you had more than 1 nodes please move only one and turn off the others)

== Prune node data

Please run following commands in SKALE Node CLI on the machine to prune the old testnet node data:

=== Turn-off SKALE node on current machine

```shell
skale node turn-off --yes
```

=== Cleanup artifacts(Run these commands one-by-one)

```shell
systemctl disable docker-lvmpy

lvremove schains

vgremove schains

rm -r .skale 
```

== Setup a node

Please follow the updated xref:network::setup-process.adoc[Setup process] doc to setup a node connected to test SKALE Network infrastructure which connected to Goerli.

Thanks!

Always with you

SKALE Team
