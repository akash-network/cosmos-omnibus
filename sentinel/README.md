# Sentinel

| | |
|---|---|
|Version|`v0.8.3`|
|Binary|`sentinelhub`|
|Directory|`.sentinelhub`|
|ENV namespace|`SENTINELHUB`|
|Repository|`https://github.com/sentinel-official/hub`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.2-sentinel-v0.8.3`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Sentinel.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/sentinel/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the Sentinel blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/sentinel/snapshot.json`|