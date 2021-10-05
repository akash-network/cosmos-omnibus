# COSMOS OMNIBUS - Run Cosmos Nodes on Akash

This is a meta package of [cosmos-sdk](//github.com/cosmos-cosmos-sdk)-based
docker images and configuration meant to make deploying onto [Akash](//github.com/ovrclk/akash)
easy and standardized across cosmos.

The goal is to have a simple way to launch any cosmos chain, with a variety of different bootstrapping options

1. "normal" boostrap - using `fastsync`.
1. Hand-made snapshots a la [cosmos-snapshots](https://github.com/c29r3/cosmos-snapshots)
1. The new `state-sync` mechanism.

Configuration is achieved using environment variables, with shortcuts available for common setups. Every aspect of the node configuration can be achieved in this way.

Additionally the node private keys can be backed up and restored from any S3 compatible storage provider, such as Sia or Storj, via [Filebase](https://filebase.com/).

## Networks

The available docker images can be found [here](https://github.com/orgs/ovrclk/packages/container/package/cosmos-omnibus).  They are
tagged with the form `$COSMOS_OMNIBUS_VERSION-$PROJECT-$PROJECT_VERSION`.

|Project|Version|Image| |
|---|---|---|---|
|[akash](https://github.com/ovrclk/akash)|`v0.12.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-akash-v0.12.1`|[Example](./akash)|
|[sentinelhub](https://github.com/sentinel-official/hub)|`v0.8.3`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-sentinelhub-v0.8.3`|[Example](./sentinelhub)|
|[gaia](https://github.com/cosmos/gaia)|`v4.2.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-gaia-v4.2.1`|[Example](./gaia)|
|[kava](https://github.com/Kava-Labs/kava)|`v0.14.2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-kava-v0.14.2`|[Example](./kava)|
|[osmosis](https://github.com/osmosis-labs/osmosis)|`v3.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-osmosis-v3.1.0`|[Example](./osmosis)|
|[persistence](https://github.com/persistenceOne/persistenceCore)|`v0.1.3`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-persistence-v0.1.3`|[Example](./persistence)|
|[juno](https://github.com/CosmosContracts/Juno)|`lucina`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-juno-lucina`|[Example](./juno)|
|[regen](https://github.com/regen-network/regen-ledger)|`v1.0.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.0.6-regen-v1.0.0`|[Example](./regen)|

## Configuration

Cosmos blockchains can be configured entirely using environment variables instead of the config files. 
Every chain has it's own prefix, but the format of the configuration is the same. 

For example to configure the `seeds` option in the `p2p` section of `config.toml`, for the Akash blockchain:

```
AKASH_P2P_SEEDS=id@node:26656
```

The namespace for each of the supported chains in the cosmos omnibus can be found in the `docker-compose.yml` files in each project directory.

The omnibus images allow some specific variables and shortcuts to configure extra functionality.

### Chain configuration

Chain config can be sourced from a `chain.json` file [as seen in the Cosmos Registry](https://github.com/cosmos/chain-registry), or from a metadata repository such as [Akash's ovrclk/net](https://github.com/ovrclk/net).

|Variable|Description|Default|Examples|
|---|---|---|---|
|`CHAIN_URL`|URL to a `chain.json` file detailing the chain meta| |`https://github.com/cosmos/chain-registry/blob/master/akash/chain.json`
|`METADATA_URL`|URL to a `net` repo in the same form as Akash| |`https://github.com/ovrclk/net/tree/master/mainnet`
|`CHAIN_ID`|The cosmos chain ID| |`akashnet-2`
|`GENESIS_URL`|URL to the genesis file in `.gz` or `.zip` format. Can be set by CHAIN_URL or METADATA_URL| |`https://raw.githubusercontent.com/ovrclk/net/master/mainnet/genesis.json`
|`VALIDATE_GENESIS`|Set to 0 to disable validation of genesis file|`1`|`0`

### P2P

See [Cosmos docs](https://docs.tendermint.com/master/nodes/configuration.html#p2p-settings) for more information. Note this can be sourced from `CHAIN_URL` or `METADATA_URL` automatically.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`P2P_SEEDS`|Seed nodes. Can be set by CHAIN_URL or GENESIS_URL| |`id@node:26656`|
|`P2P_PERSISTENT_PEERS`|Persistent peers. Can be set by CHAIN_URL or GENESIS_URL| |`id@node:26656`|

### Private key backup/restore

On boot, the container can restore a private key from any S3 storage provider. If this is configured and the key doesn't exist in S3 yet, it will be uploaded from the node.

This allows for a persistent node ID and validator key on Akash's ephemeral storage.

[Filebase](https://filebase.com/) is a great way to use S3 with decentralised hosting such as Sia.

The `node_key.json` and `priv_validator_key.json` are both backed up, and can be encrypted with a password.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`S3_KEY`|S3 access key| | |
|`S3_SECRET`|S3 secret key| | |
|`S3_HOST`|The S3 API host|`https://s3.filebase.com`|`s3.us-east-1.amazonaws.com`|
|`KEY_PATH`|Bucket and directory to backup/restore to| |`bucket/nodes/node_1`|
|`KEY_PASSWORD`|An optional password to encrypt your private keys. Shouldn't be optional| | |

### Statesync

Some shortcuts for enabling statesync. Statesync requires 2x nodes with snapshots enabled.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`STATESYNC_SNAPSHOT_INTERVAL`|Take a snapshot to provide statesync every X blocks| |`500`|
|`STATESYNC_ENABLE`|Enabling statesyncing from a node. Default `true` if `STATESYNC_RPC_SERVERS` is set| | |
|`STATESYNC_RPC_SERVERS`|Comma separated list of RPC nodes with snapshots enabled| |`ip:26657,ip2:26657`|
|`TRUSTED_NODE`|A trusted node to obtain trust height and hash from. Defaults to the first `STATESYNC_RPC_SERVERS` if set| |`ip:26657`|
|`STATESYNC_TRUST_PERIOD`|Trust period for the statesync snapshot|`168h0m0s`| |
|`STATESYNC_TRUST_HEIGHT`|Obtained from TRUSTED_NODE or first STATESYNC_RPC_SERVERS| | |
|`STATESYNC_TRUST_HASH`|Obtained from TRUSTED_NODE or first STATESYNC_RPC_SERVERS| | |

### Snapshot restore

The node `data` directory can be restored from a `.tar` or `.tar.gz` file stored on a public URL. 
This can be from a specific URL, or from a base URL and a file matching a given pattern.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`BOOTSTRAP`|Whether to bootstrap the node from the snapshot URL|`1`|`0`|
|`SNAPSHOT_URL`|A URL to a `.tar` or `.tar.gz` file| |`http://135.181.60.250/akash/akashnet-2_2021-06-16.tar`|
|`SNAPSHOT_FORMAT`|The format of the snapshot file|`tar.gz`|`tar`|
|`SNAPSHOT_BASE_URL`|A base URL to a directory containing backup files| |`http://135.181.60.250/akash`|
|`SNAPSHOT_PATTERN`|The pattern of the file in the `BASE_URL`|`$CHAIN_ID.*$SNAPSHOT_FORMAT`|`foobar.*tar.gz`|

### Shortcuts

See [Cosmos docs](https://docs.tendermint.com/master/nodes/configuration.html) for more information

|Variable|Description|Default|Examples|
|---|---|---|---|
|`FASTSYNC_VERSION`|The fastsync version| |`v2`|
|`MINIMUM_GAS_PRICES`|Minimum gas prices| |`0.025uakt`|
|`PRUNING`|How much of the chain to prune| |`nothing`|
|`DEBUG`|Set to `1` to output all environment variables on boot| |`1`|

## Running on Akash

See the `deploy.yml` example file in each chain directory which details the minimum configuration required. Use the above configuration options to add functionality.

## Running locally

See the `docker-compose.yml` example file to run each node locally using `docker-compose up`

## Examples

See the [_examples](./_examples) directory for some common setups, including:

- [Statesync](./_examples/statesync)
- [Load Balanced RPC Nodes](./_examples/load-balanced-rpc-nodes)
- [Validator and Public Sentries](./_examples/validator-and-public-sentries)
- [Validator with Private Sentries](./_examples/validator-and-private-sentries)

## TODO

- [ ] Backup node data to S3 on schedule
- [ ] More chains..

## Contributing

Adding a new chain is easy:

- Ideally setup a `chain.json` or `net` repository to provide a single source of truth for setup info
- Add a project directory based on the existing projects
- The [github workflow](https://github.com/ovrclk/cosmos-omnibus/blob/master/.github/workflows/publish.yaml) to create an image for your chain

Submit a PR or an issue if you want to see any specific chains.
