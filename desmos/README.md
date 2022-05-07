# Desmos

| | |
|---|---|
|Version|`v2.3.1`|
|Binary|`desmos`|
|Directory|`.desmos`|
|ENV namespace|`DESMOS`|
|Repository|`https://github.com/desmos-labs/desmos`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.1-desmos-v2.3.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Desmos.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/desmos/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the Desmos blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/desmos/snapshot.json`|
