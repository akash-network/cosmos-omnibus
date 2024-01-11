# Kava

| | |
|---|---|
|Version|`v0.25.0`|
|Binary|`kava`|
|Directory|`.kava`|
|ENV namespace|`KAVA`|
|Repository|`https://github.com/Kava-Labs/kava`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-kava-v0.25.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Kava.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/kava/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|

## ChainLayer Quicksync

ChainLayer provide snapshots for Kava as part of their [Quicksync service](https://quicksync.io/networks/kava.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/kava.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.kava.json`|
