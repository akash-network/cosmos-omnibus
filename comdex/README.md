# Comdex

| | |
|---|---|
|Version|`v0.1.1`|
|Binary|`comdex`|
|Directory|`.comdex`|
|ENV namespace|`COMDEX`|
|Repository|`https://github.com/comdex-official/comdex`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.7-comdex-v0.1.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Comdex.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/comdex/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the Comdex blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/comdex/snapshot.json`|
