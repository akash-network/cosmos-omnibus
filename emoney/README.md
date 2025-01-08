# e-Money

| | |
|---|---|
|Version|`v1.2.0`|
|Binary|`emd`|
|Directory|`.emd`|
|ENV namespace|`EMD`|
|Repository|`https://github.com/e-money/em-ledger`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.1.1-emoney-v1.2.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/emoney/chain.json) for e-Money.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).
