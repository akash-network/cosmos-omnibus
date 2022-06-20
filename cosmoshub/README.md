# Cosmos Hub

| | |
|---|---|
|Version|`v7.0.1`|
|Binary|`gaiad`|
|Directory|`.gaia`|
|ENV namespace|`GAIAD`|
|Repository|`https://github.com/cosmos/gaia`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.2.0-cosmoshub-v7.0.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Cosmos Hub.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/chain.json`|

## Snapshot restore

ChainLayer provide snapshots for Cosmos Hub as part of their [Quicksync service](https://quicksync.io/networks/cosmos.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/cosmos.json`|