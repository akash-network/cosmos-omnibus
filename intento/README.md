# Intento

| | |
|---|---|
|Version|`v1.1.0-hotfix.13`|
|Binary|`intentod`|
|Directory|`.intento`|
|ENV namespace|`INTENTOD`|
|Repository|`https://github.com/trstlabs/intento`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.43-intento-v1.1.0-hotfix.13`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/intento/chain.json) for Intento.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
