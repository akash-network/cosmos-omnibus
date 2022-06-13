# Bandchain

| | |
|---|---|
|Version|`v2.3.3`|
|Binary|`bandd`|
|Directory|`.band`|
|ENV namespace|`BAND`|
|Repository|`https://github.com/bandprotocol/chain`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.7-bandchain-v2.3.3`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Bandchain.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/bandchain/chain.json`|

## Snapshot restore

ChainLayer provide snapshots for Bandchain as part of their [Quicksync service](https://quicksync.io/networks/band.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/band.json`|