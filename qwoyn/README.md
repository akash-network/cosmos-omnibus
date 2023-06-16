# Qwoyn Network

| | |
|---|---|
|Version|`v5.0.2`|
|Binary|`qwoynd`|
|Directory|`.qwoynd`|
|ENV namespace|`QWOYND`|
|Repository|`https://github.com/cosmic-horizon/QWOYN`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.3.36-qwoyn-v5.0.2`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Qwoyn Network chain.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/qwoyn/chain.json`|

## ChainLayer Quicksync

ChainLayer provide snapshots for Qwoyn Network as part of their [Quicksync service](https://quicksync.io/networks/qwoyn.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/qwoyn.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.qwoyn.json`|
