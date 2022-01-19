# Gravitybridge

| | |
|---|---|
|Version|`v1.3.3`|
|Binary|`gravity`|
|Directory|`.gravity`|
|ENV namespace|`GRAVITY`|
|Repository|`https://github.com/Gravity-Bridge/Gravity-Bridge`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.22-gravitybridge-v1.3.3`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Gravitybridge.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/gravitybridge/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the GravityBridge blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/gravitybridge/snapshot.json`|
