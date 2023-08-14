# Migaloo

| | |
|---|---|
|Version|`v2.2.6`|
|Binary|`migalood`|
|Directory|`.migalood`|
|ENV namespace|`MIGALOOD`|
|Repository|`https://github.com/White-Whale-Defi-Platform/migaloo-chain`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.3.44-migaloo-v2.2.6`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Migaloo

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/migaloo/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
