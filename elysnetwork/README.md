# Elys Network

| | |
|---|---|
|Version|`v0.29.12`|
|Binary|`elysd`|
|Directory|`.elys`|
|ENV namespace|`ELYSD`|
|Repository|`https://github.com/elys-network/elys`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.4.27-elysnetwork-v0.29.12`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Elys Network.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/testnets/elystestnet/chain.json`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
