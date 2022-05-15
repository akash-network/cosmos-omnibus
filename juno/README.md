# Juno

| | |
|---|---|
|Version|`v5.0.1`|
|Binary|`junod`|
|Directory|`.juno`|
|ENV namespace|`JUNOD`|
|Repository|`https://github.com/CosmosContracts/Juno`|
|Image|`ghcr.io/ovrclk/cosmos-omnibus:v0.1.3-juno-v5.0.1`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run locally using the [example docker-compose.yml](./docker-compose.yml)

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes up to date chain info for Juno.

Currently no seeds or peers are listed so these can be configured manually [from the Juno docs](https://docs.junochain.com/validators/joining-mainnet).

|Variable|Value|
|---|---|
|`CHAIN_JSON`|`https://raw.githubusercontent.com/cosmos/chain-registry/master/juno/chain.json`|
|`GENESIS_URL`|`https://github.com/CosmosContracts/mainnet/blob/main/juno-1/genesis.json?raw=true`|
|`P2P_PERSISTENT_PEERS`|`b1f46f1a1955fc773d3b73180179b0e0a07adce1@162.55.244.250:39656,7f593757c0cde8972ce929381d8ac8e446837811@178.18.255.244:26656,7b22dfc605989d66b89d2dfe118d799ea5abc2f0@167.99.210.65:26656,4bd9cac019775047d27f9b9cea66b25270ab497d@137.184.7.164:26656,bd822a8057902fbc80fd9135e335f0dfefa32342@65.21.202.159:38656,15827c6c13f919e4d9c11bcca23dff4e3e79b1b8@51.38.52.210:38656,e665df28999b2b7b40cff2fe4030682c380bf294@188.40.106.109:38656,92804ce50c85ff4c7cf149d347dd880fc3735bf4@34.94.231.154:26656,795ed214b8354e8468f46d1bbbf6e128a88fe3bd@34.127.19.222:26656,ea9c1ac0e91639b2c7957d9604655e2263abe4e1@185.181.103.136:26656`|
|`P2P_SEEDS`|`2484353dab0b2c1275765b8ffa2c50b3b36158ca@seed-node.junochain.com:26656,ef2315d81caa27e4b0fd0f267d301569ee958893@juno-seed.blockpane.com:26656`|


## Snapshot restore

Akash provide daily snapshots of the Juno blockchain taken at midnight UTC.

|Variable|Value|
|---|---|
|`SNAPSHOT_JSON`|`https://cosmos-snapshots.s3.filebase.com/juno/snapshot.json`|
