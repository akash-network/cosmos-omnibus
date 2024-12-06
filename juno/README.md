# Juno

| | |
|---|---|
|Version|`v25.0.0`|
|Binary|`junod`|
|Directory|`.juno`|
|ENV namespace|`JUNOD`|
|Repository|`https://github.com/CosmosContracts/juno`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.0.3-juno-v25.0.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/juno/chain.json) for Juno.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).

## Suggested configuration

The following configuration is recommended for Juno nodes.

|Variable|Value|
|---|---|
|`GENESIS_FILENAME`|`juno-phoenix2-genesis.json`|
|`JUNOD_IAVL_CACHE_SIZE`|`781250`|
|`JUNOD_IAVL_DISABLE_FASTNODE`|`false`|

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, seeds, statesync, addrbooks and pruned snapshots among other features.

The following configuration is available for Juno nodes. [See the documentation](../README.md#polkachu-services) for more information.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`P2P_SEEDS_POLKACHU`|`1`|
|`P2P_PEERS_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
|`ADDRBOOK_POLKACHU`|`1`|

Polkachu also provide pruned snapshots for Juno. Find the [latest snapshot](https://polkachu.com/tendermint_snapshots/akash) and apply it using the `SNAPSHOT_URL` variable.
