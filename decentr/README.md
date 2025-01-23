# Decentr

| | |
|---|---|
|Version|`v1.6.4`|
|Binary|`decentrd`|
|Directory|`.decentr`|
|ENV namespace|`DECENTRD`|
|Repository|`https://github.com/Decentr-net/decentr`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.0-decentr-v1.6.4`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/decentr/chain.json) for Decentr.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
