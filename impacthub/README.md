# Impact Hub

| | |
|---|---|
|Version|`v0.18.1`|
|Binary|`ixod`|
|Directory|`.ixod`|
|ENV namespace|`IXOD`|
|Repository|`https://github.com/ixofoundation/ixo-blockchain`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.23-impacthub-v0.18.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/impacthub/chain.json) for Impact Hub.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
