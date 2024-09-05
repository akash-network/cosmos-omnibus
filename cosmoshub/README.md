# Cosmos Hub

| | |
|---|---|
|Version|`v19.2.0`|
|Binary|`gaiad`|
|Directory|`.gaia`|
|ENV namespace|`GAIAD`|
|Repository|`https://github.com/cosmos/gaia`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.4.27-cosmoshub-v19.2.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Cosmos Hub.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|

## ChainLayer Quicksync

ChainLayer provide snapshots for Cosmos Hub as part of their [Quicksync service](https://quicksync.io/networks/cosmos.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/cosmos.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.cosmos.json`|
