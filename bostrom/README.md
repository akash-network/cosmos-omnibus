# bostrom

| | |
|---|---|
|Version|`v0.3.2`|
|Binary|`cyber`|
|Directory|`.cyber`|
|ENV namespace|`CYBER`|
|Repository|`https://github.com/cybercongress/go-cyber`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.0-bostrom-v0.3.2`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/bostrom/chain.json) for bostrom.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
