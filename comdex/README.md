# Comdex

| | |
|---|---|
|Version|`v9.1.0`|
|Binary|`comdex`|
|Directory|`.comdex`|
|ENV namespace|`COMDEX`|
|Repository|`https://github.com/comdex-official/comdex`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.3.25-comdex-v9.1.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Comdex.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/comdex/chain.json`|

## Polkachu Tools

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
