# Terp-Network

| | |
|---|---|
|Version|`v5.0.3`|
|Binary|`terpd`|
|Directory|`.terp`|
|ENV namespace|`TERPD`|
|Repository|`https://github.com/terpnetwork/terp-core`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.38-terpnetwork-v5.0.3`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

> ### Try out our dedicated sentry-node array deployment scripting, [O-line](https://github.com/permissionlessweb/o-line/tree/master/plays/oline-sdl), powered by cosmos-omnibus & [akash-deploy-rs](https://github.com/permissionlessweb/akash-deploy-rs)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/terpnetwork/chain.json) for Terp-Network.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
