# Kava

| | |
|---|---|
|Version|`v0.25.0`|
|Binary|`kava`|
|Directory|`.kava`|
|ENV namespace|`KAVA`|
|Repository|`https://github.com/Kava-Labs/kava`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v1.2.23-kava-v0.25.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info](https://raw.githubusercontent.com/cosmos/chain-registry/master/kava/chain.json) for Kava.

This will be used automatically unless overridden with the `CHAIN_JSON` variable (use `0` to disable).

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/networks/kava) make bootstrapping a node extremely easy. They provide live peers, seeds, statesync, addrbooks and pruned snapshots among other features.

The following configuration is available for Kava nodes. [See the documentation](../README.md#polkachu-services) for more information.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`P2P_SEEDS_POLKACHU`|`1`|
|`P2P_PEERS_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
|`ADDRBOOK_POLKACHU`|`1`|

Polkachu also provide pruned snapshots for Kava. Find the [latest snapshot](https://polkachu.com/tendermint_snapshots/kava) and apply it using the `SNAPSHOT_URL` variable.
