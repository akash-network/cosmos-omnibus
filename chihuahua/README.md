# Chihuahua

| | |
|---|---|
|Version|`v2.1.0`|
|Binary|`chihuahuad`|
|Directory|`.chihuahua`|
|ENV namespace|`CHIHUAHUAD`|
|Repository|`https://github.com/ChihuahuaChain/chihuahua`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.4-chihuahua-v2.1.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Chihuahua.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/chihuahua/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`SNAPSHOT_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
