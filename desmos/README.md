# Desmos

| | |
|---|---|
|Version|`v6.2.0`|
|Binary|`desmos`|
|Directory|`.desmos`|
|ENV namespace|`DESMOS`|
|Repository|`https://github.com/desmos-labs/desmos`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.0-desmos-v6.2.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/desmos/chain.json) for Desmos.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
