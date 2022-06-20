# Chronic Chain

| | |
|---|---|
|Version|`v1.1.0`|
|Binary|`chtd`|
|Directory|`.cht`|
|ENV namespace|`CHTD`|
|Repository|`https://github.com/ChronicNetwork/cht`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.7-chronicnetwork-v1.1.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Chronic Network.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/chronicnetwork/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the Chronic blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/chronicnetwork/snapshot.json`|