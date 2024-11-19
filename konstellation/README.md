# Konstellation

| | |
|---|---|
|Version|`v0.5.0`|
|Binary|`knstld`|
|Directory|`.knstld`|
|ENV namespace|`KNSTLD`|
|Repository|`https://github.com/konstellation/konstellation`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.0.0-konstellation-v0.5.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/konstellation/chain.json) for Konstellation.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
