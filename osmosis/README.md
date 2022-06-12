# Osmosis

| | |
|---|---|
|Version|`v10.0.0`|
|Binary|`osmosisd`|
|Directory|`.osmosisd`|
|ENV namespace|`OSMOSISD`|
|Repository|`https://github.com/omosis-labs/osmosis`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.6-osmosis-v10.0.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Osmosis.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/osmosis/chain.json`|

## Snapshot restore

ChainLayer provide snapshots for Osmosis as part of their [Quicksync service](https://quicksync.io/networks/osmosis.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/osmosis.json`|
