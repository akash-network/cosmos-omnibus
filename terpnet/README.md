# TerpNet

| | |
|---|---|
|Version|`v0.1.0`|
|Binary|`terp`|
|Directory|`.terp`|
|ENV namespace|`TERP`|
|Repository|`https://github.com/terpnetworkr/terp-core`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.4-terp-v0.1.0`|

## Examples

- Run on TerpNet with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

TerpNet provide up to date chain information in their 
[terpnetwork/awesome-terpnetwork](https://github.com/terpnetwork/awesome-terpnetwork) 
repository.

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/terpnetwork/test-net/master/athena-1/chain.json`|

## Suggested configuration

TerpNet suggests setting a minimum gas price and using Fastsync v0.

|Variable|Value|
|---|---|
|`MINIMUM_GAS_PRICES`|`0.025upersyx`|
|`FASTSYNC_VERSION`|`v0`|


## TerpNet Snapshots

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`TBD`|
