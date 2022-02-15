# e-Money

| | |
|---|---|
|Version|`v1.1.3`|
|Binary|`emd`|
|Directory|`.emd`|
|ENV namespace|`EMD`|
|Repository|`https://github.com/e-money/em-ledger`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.27-emoney-v1.1.3`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for e-Money.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/emoney/chain.json`|

## Suggested configuration

e-Money does not support the validate-genesis command so this should be disabled

|Variable|Value|
|---|---|
|`VALIDATE_GENESIS`|`0`|
