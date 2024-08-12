# Cryptoorgchain

| | |
|---|---|
|Version|`v4.2.9`|
|Binary|`chain-maind`|
|Directory|`.chain-maind`|
|ENV namespace|`CHAIN_MAIND`|
|Repository|`https://github.com/crypto-org-chain/chain-main`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.4.24-cryptoorgchain-v4.2.9`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Cryptoorgchain.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/cryptoorgchain/chain.json`|

## ChainLayer Quicksync

ChainLayer provide snapshots for Cryptoorgchain as part of their [Quicksync service](https://quicksync.io/networks/crypto.html).

|Variable|Value|
|---|---|
|`SNAPSHOT_QUICKSYNC`|`https://quicksync.io/crypto.json`|
|`ADDRBOOK_URL`|`https://quicksync.io/addrbook.crypto.json`|
