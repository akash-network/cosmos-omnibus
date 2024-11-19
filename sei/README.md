# Sei

| | |
|---|---|
|Version|`v5.7.5`|
|Binary|`seid`|
|Directory|`.sei`|
|ENV namespace|`SEID`|
|Repository|`https://github.com/sei-protocol/sei-chain`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.0.0-sei-v5.7.5`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/sei/chain.json) for Sei.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, seeds, statesync, addrbooks and pruned snapshots among other features.

The following configuration is available for Sei nodes. [See the documentation](../README.md#polkachu-services) for more information.

|Variable|Value|
|---|---|
|`STATESYNC_POLKACHU`|`1`|

Polkachu also provide pruned snapshots for Sei. Find the [latest snapshot](https://polkachu.com/tendermint_snapshots/akash) and apply it using the `SNAPSHOT_URL` variable.
