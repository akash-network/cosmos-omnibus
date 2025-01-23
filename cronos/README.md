# Cronos

| | |
|---|---|
|Version|`v1.4.0`|
|Binary|`cronosd`|
|Directory|`.cronos`|
|ENV namespace|`CRONOSD`|
|Repository|`https://github.com/crypto-org-chain/cronos`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.0-cronos-v1.4.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/cronos/chain.json) for Cronos.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
