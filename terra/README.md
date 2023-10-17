# Terra

| | |
|---|---|
|Version|`v0.5.18`|
|Binary|`terrad`|
|Directory|`.terra`|
|ENV namespace|`TERRAD`|
|Repository|`https://github.com/terra-money/core`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.3.51-terra-v0.5.18`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Terra.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/terra/chain.json`|

## ChainLayer Quicksync

ChainLayer provide snapshots for Terra as part of [their Quicksync service](https://quicksync.io/networks/terra.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/terra.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.terra.json`|
