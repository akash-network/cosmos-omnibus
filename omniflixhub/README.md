# OmniFlix

| | |
|---|---|
|Version|`v6.1`|
|Binary|`omniflixhubd`|
|Directory|`.omniflixhub`|
|ENV namespace|`OMNIFLIXHUBD`|
|Repository|`https://github.com/OmniFlix/omniflixhub`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.42-omniflixhub-v6.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/omniflixhub/chain.json) for OmniFlix.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
