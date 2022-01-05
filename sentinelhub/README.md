# Sentinelhub

| | |
|---|---|
|Version|`v0.8.3`|
|Binary|`sentinelhub`|
|Directory|`.sentinelhub`|
|ENV namespace|`SENTINELHUB`|
|Repository|`https://github.com/sentinel-official/hub`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.10-sentinelhub-v0.8.3`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Sentinelhub.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/sentinel/chain.json`|

## Suggested configuration

The validate-genesis command fails for v0.8.3 so this should be disabled for now

|Variable|Value|
|---|---|
|`VALIDATE_GENESIS`|`0`|
