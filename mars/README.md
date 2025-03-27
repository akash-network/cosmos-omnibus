# Mars Hub

| | |
|---|---|
|Version|`v1.0.2`|
|Binary|`marsd`|
|Directory|`.mars`|
|ENV namespace|`MARSD`|
|Repository|`https://github.com/mars-protocol/hub.git`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.11-mars-v1.0.2`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/mars/chain.json) for Mars Hub.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
