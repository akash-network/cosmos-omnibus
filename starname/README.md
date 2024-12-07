# Starname

| | |
|---|---|
|Version|`v0.11.5`|
|Binary|`starnamed`|
|Directory|`.starnamed`|
|ENV namespace|`STARNAMED`|
|Repository|`https://github.com/iov-one/starnamed`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.0.3-starname-v0.11.5`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/starname/chain.json) for Starname.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
