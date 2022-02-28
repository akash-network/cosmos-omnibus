# Bitcanna

| | |
|---|---|
|Version|`v.1.3.1`|
|Binary|`bcnad`|
|Directory|`.bcna`|
|ENV namespace|`BCNAD`|
|Repository|`https://github.com/BitCannaGlobal/bcna`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.27-bitcanna-v.1.3.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Bitcanna.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/bitcanna/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the Bitcanna blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/bitcanna/snapshot.json`|
