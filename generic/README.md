# Osmosis

| | |
|---|---|
|Version|`v7.0.2`|
|Binary|`osmosisd`|
|Directory|`.osmosisd`|
|ENV namespace|`OSMOSISD`|
|Repository|`https://github.com/omosis-labs/osmosis`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.28-osmosis-v7.0.2`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Osmosis.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/osmosis/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the Osmosis blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/osmosis/snapshot.json`|
