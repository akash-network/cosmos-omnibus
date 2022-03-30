# Akash

| | |
|---|---|
|Version|`v0.14.1`|
|Binary|`akash`|
|Directory|`.akash`|
|ENV namespace|`AKASH`|
|Repository|`https://github.com/ovrclk/akash`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.30-akash-v0.14.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

Akash provide up to date chain information in their [ovrclk/net](https://github.com/ovrclk/net) repository.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/ovrclk/net/master/mainnet/meta.json`|

## Snapshot restore

Akash provide daily snapshots of the Akash blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/akash/snapshot.json`|

## Suggested configuration

Akash suggests setting a minimum gas price and using Fastsync v2.

|Variable|Value|
|---|---|
|`MINIMUM_GAS_PRICES`|`0.025uakt`|
|`FASTSYNC_VERSION`|`v2`|
