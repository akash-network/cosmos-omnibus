# Lum Network

| | |
|---|---|
|Version|`v1.0.5`|
|Binary|`lumnetworkd`|
|Directory|`.lumd`|
|ENV namespace|`LUMNETWORK`|
|Repository|`https://github.com/lum-network/chain`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.2.2-lumnetwork-v1.0.5`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Lum Network chain.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/lumnetwork/chain.json`|

## ChainLayer Quicksync

ChainLayer provide snapshots for Lum Network as part of their [Quicksync service](https://quicksync.io/networks/lum.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/lum.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.lum.json`|
