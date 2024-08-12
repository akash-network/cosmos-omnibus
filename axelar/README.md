# Axelar

| | |
|---|---|
|Version|`v0.34.0`|
|Binary|`axelard`|
|Directory|`.axelar`|
|ENV namespace|`AXELAR`|
|Repository|`https://github.com/axelarnetwork/axelar-core`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.4.24-axelar-v0.34.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Axelar.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/axelar/chain.json`|

## Suggested configuration

Axelar suggests setting a minimum gas price and using Fastsync v0.

|Variable|Value|
|---|---|
|`MINIMUM_GAS_PRICES`|`0.007uaxl`|
|`FASTSYNC_VERSION`|`v0`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
