# Rizon

| | |
|---|---|
|Version|`v0.4.1`|
|Binary|`rizond`|
|Directory|`.rizon`|
|ENV namespace|`RIZOND`|
|Repository|`https://github.com/rizon-world/rizon`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.1.1-rizon-v0.4.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/rizon/chain.json) for Rizon.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
