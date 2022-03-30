# Sifchain

| | |
|---|---|
|Version|`v0.10.1`|
|Binary|`sifnoded`|
|Directory|`.sifnoded`|
|ENV namespace|`SIFNODED`|
|Repository|`https://github.com/Sifchain/sifnode`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.30-sifchain-v0.10.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Sifchain.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/sifchain/chain.json`|

## Snapshot restore

Akash provide daily snapshots of the Sifchain blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/sifchain/snapshot.json`|

## Suggested configuration

The validate-genesis command fails for betanet-0.9.12 so this should be disabled for now

|Variable|Value|
|---|---|
|`VALIDATE_GENESIS`|`0`|
