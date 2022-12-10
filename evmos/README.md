# Evmos

| | |
|---|---|
|Version|`v9.1.0`|
|Binary|`evmosd`|
|Directory|`.evmosd`|
|ENV namespace|`EVMOSD`|
|Repository|`https://github.com/evmos/evmos`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.17-evmos-v9.1.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Evmos.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/evmos/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`SNAPSHOT_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|

## Skip MEV support

If you would like to use this chain with [Skip Protocol](https://skip.money/), an additional image is available with Skip's version of Tendermint pre-installed.

| | |
|---|---|
|Skip Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.17-evmos-v9.1.0-skip`|