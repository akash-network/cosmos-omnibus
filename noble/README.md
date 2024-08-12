# Noble

| | |
|---|---|
|Version|`v5.0.0`|
|Binary|`nobled`|
|Directory|`.noble`|
|ENV namespace|`NOBLED`|
|Repository|`https://github.com/noble-assets/noble`|
|Image|`ghcr.io/akash-network/cosmos-omnibus:v0.4.24-noble-v5.0.0`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, statesync and pruned snapshots.

Note you should choose between statesync and snapshot bootstrapping, snapshot will take precedence.

|Variable|Value|
|---|---|
|`P2P_POLKACHU`|`1`|
|`STATESYNC_POLKACHU`|`1`|
