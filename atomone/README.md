# AtomOne

| | |
|---|---|
|Version|`v3.3.0`|
|Binary|`atomoned`|
|Directory|`.atomone`|
|ENV namespace|`ATOMONED`|
|Repository|`https://github.com/atomone-hub/atomone`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.42-atomone-v3.3.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/atomone/chain.json) for AtomOne.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
