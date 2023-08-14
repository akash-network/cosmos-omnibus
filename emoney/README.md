# e-Money

| | |
|---|---|
|Version|`v1.2.0`|
|Binary|`emd`|
|Directory|`.emd`|
|ENV namespace|`EMD`|
|Repository|`https://github.com/e-money/em-ledger`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.3.44-emoney-v1.2.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for e-Money.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/emoney/chain.json`|

## ChainLayer Quicksync

ChainLayer provide snapshots for e-Money as part of their [Quicksync service](https://quicksync.io/networks/emoney.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/emoney.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.emoney.json`|
