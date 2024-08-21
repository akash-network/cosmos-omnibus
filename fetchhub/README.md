# Fetch.ai fetchhub chain

| | |
|---|---|
|Version|`v0.11.3`|
|Binary|`fetchd`|
|Directory|`.fetchd`|
|ENV namespace|`FETCH`|
|Repository|`https://github.com/fetchai/fetchd`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.4.25-fetchhub-v0.11.3`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Fetch.ai chain.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/fetchhub/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
