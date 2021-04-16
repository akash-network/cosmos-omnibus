# COSMOS OMNIBUS - Run Cosmos Nodes on Akash

**WORK IN PROGRESS**

This is a meta package of [cosmos-sdk](//github.com/cosmos-cosmos-sdk)-based
docker images and configuration meant to make deploying onto [Akash](//github.com/ovrclk/akash)
easy and standardized across cosmos.

The goal is to have a simple way to launch any cosmos chain, with a variety of different bootstrapping options

1. "normal" boostrap - using `fastsync`.
1. Hand-made snapshots a la [cosmos-snapshots](https://github.com/c29r3/cosmos-snapshots)
1. The new `state-sync` mechanism.

## Networks

The available docker images can be found [here](https://github.com/orgs/ovrclk/packages/container/package/cosmos-omnibus).  They are
tagged with the form `$COSMOS_OMNIBUS_VERSION-$PROJECT-$PROJECT_VERSION`.

|Project|Repository|Version|Image|
|---|---|---|
|`akash`|https://github.com/ovrclk/akash|`v0.12.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.1-akash-v0.12.1`|
|`gaiad`|https://github.com/cosmos/gaia|`v0.4.12`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.1-gaiad-v4.12`|
|`dvpn`|https://github.com/sentinel-official/hub|`v0.5.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.1-dvpn-v0.5.0`|
|`kava`|https://github.com/Kava-Labs/kava|`v0.14.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.1-kava-v0.14.1`|

## TODO

... everything?
