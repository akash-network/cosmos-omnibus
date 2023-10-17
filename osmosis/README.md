# Osmosis

| | |
|---|---|
|Version|`v19.0.0`|
|Binary|`osmosisd`|
|Directory|`.osmosisd`|
|ENV namespace|`OSMOSISD`|
|Repository|`https://github.com/omosis-labs/osmosis`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.3.51-osmosis-v19.0.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Osmosis.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/osmosis/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|

## ChainLayer Quicksync

ChainLayer provide snapshots for Osmosis as part of their [Quicksync service](https://quicksync.io/networks/osmosis.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/osmosis.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.osmosis.json`|
