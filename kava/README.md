# Kava

| | |
|---|---|
|Version|`v0.16.1`|
|Binary|`kava`|
|Directory|`.kava`|
|ENV namespace|`KA`|
|Repository|`https://github.com/Kava-Labs/kava`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.7-kava-v0.16.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Kava.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/kava/chain.json`|

## Snapshot restore

ChainLayer provide snapshots for Kava as part of their [Quicksync service](https://quicksync.io/networks/kava.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/kava.json`|

