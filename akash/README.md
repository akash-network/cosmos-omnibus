# Akash

| | |
|---|---|
|Version|`v0.26.1`|
|Binary|`akash`|
|Directory|`.akash`|
|ENV namespace|`AKASH`|
|Repository|`https://github.com/akash-network/node`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.3.50-akash-v0.26.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

Akash provide up to date chain information in their [akash-network/net](https://github.com/akash-network/net) repository.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/akash-network/net/main/mainnet/meta.json`|

## Suggested configuration

Akash suggests setting a minimum gas price and using Fastsync v0.

|Variable|Value|
|---|---|
|`MINIMUM_GAS_PRICES`|`0.025uakt`|
|`FASTSYNC_VERSION`|`v0`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
