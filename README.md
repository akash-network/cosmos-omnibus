# COSMOS OMNIBUS - Run Cosmos Nodes on Akash

This is a meta package of [cosmos-sdk](https://github.com/cosmos/cosmos-sdk)-based
docker images and configuration meant to make deploying onto [Akash](//github.com/ovrclk/akash)
easy and standardized across cosmos.

The goal is to have a simple way to launch any cosmos chain, with a variety of different bootstrapping options

1. ["normal" boostrap](#shortcuts) - using `fastsync`.
1. [Hand-made snapshots](#snapshot-restore) a la [cosmos-snapshots](https://github.com/c29r3/cosmos-snapshots)
1. [The new `state-sync` mechanism](#statesync).

Configuration is achieved using environment variables, with shortcuts available for common setups. Every aspect of the node configuration can be achieved in this way.

Additional features are included to make running a node as simple as possible

1. [Chain configuration can be sourced from a remote JSON file](#chain-configuration)
1. [Genesis file can be downloaded and unzipped in various ways](#chain-configuration)
1. [Private keys can be backed up and restored](#private-key-backuprestore) from any S3 compatible storage provider, such as Sia or Storj via [Filebase](https://filebase.com/).
1. [Snapshots of a nodes data directory](#snapshot-backup) can be created at a certain time or day and uploaded to an S3 storage provider

## Generic image (binary downloaded at runtime)

Omnibus has a generic base image which can download the required binary at runtime. This is useful for chain upgrades, testnets, or using a different version than Omnibus primarily supports.

This generic image provides the Omnibus scripts and configuration helpers, and nothing else. Set the `BINARY_URL` environment variable to a `.zip`, `.tar` or `.tar.gz` URL, and configure `PROJECT`, `PROJECT_DIR` and `PROJECT_BIN`. Alternatively provide a [Chain Registry](https://github.com/cosmos/chain-registry) `CHAIN_JSON` to configure everything automatically (where data is available).

Image URL: `ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-generic`

```yaml
services:
  node:
    image: ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-generic
    env:
      - MONIKER=my-moniker-1
      - CHAIN_JSON=https://raw.githubusercontent.com/ovrclk/net/master/edgenet/meta.json
      - BINARY_ZIP_PATH=akash_0.15.0-rc14_linux_amd64/akash
```

More information on the generic image can be found at [/generic](./generic/), and configuration is detailed in depth below.

## Networks (pre-built images)

The available docker images can be found [here](https://github.com/orgs/ovrclk/packages/container/package/cosmos-omnibus).  They are
tagged with the form `$COSMOS_OMNIBUS_VERSION-$PROJECT-$PROJECT_VERSION`.

|Project|Version|Image| |
|---|---|---|---|
|[agoric](https://github.com/Agoric/ag0)|`agoric-upgrade-7-2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-agoric-agoric-upgrade-7-2`|[Example](./agoric)|
|[akash](https://github.com/ovrclk/akash)|`v0.18.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-akash-v0.18.1`|[Example](./akash)|
|[assetmantle](https://github.com/AssetMantle/node)|`v0.3.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-assetmantle-v0.3.0`|[Example](./assetmantle)|
|[autonomy](https://github.com/AutonomyNetwork/autonomy-chain)|`v1.2.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-autonomy-v1.2.1`|[Example](./autonomy)|
|[bandchain](https://github.com/bandprotocol/chain)|`v2.3.6`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-bandchain-v2.3.6`|[Example](./bandchain)|
|[bitcanna](https://github.com/BitCannaGlobal/bcna)|`v1.5.3`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-bitcanna-v1.5.3`|[Example](./bitcanna)|
|[bitsong](https://github.com/bitsongofficial/go-bitsong)|`v0.12.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-bitsong-v0.12.0`|[Example](./bitsong)|
|[bostrom](https://github.com/cybercongress/go-cyber)|`v0.3.2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-bostrom-v0.3.2`|[Example](./bostrom)|
|[cerberus](https://github.com/cerberus-zone/cerberus)|`v2.0.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-cerberus-v2.0.1`|[Example](./cerberus)|
|[cheqd](https://github.com/cheqd/cheqd-node)|`0.6.9`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-cheqd-0.6.9`|[Example](./cheqd)|
|[chihuahua](https://github.com/ChihuahuaChain/chihuahua)|`v4.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-chihuahua-v4.1.0`|[Example](./chihuahua)|
|[comdex](https://github.com/comdex-official/comdex)|`v6.0.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-comdex-v6.0.1`|[Example](./comdex)|
|[cosmoshub](https://github.com/cosmos/gaia)|`v7.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-cosmoshub-v7.1.0`|[Example](./cosmoshub)|
|[cronos](https://github.com/crypto-org-chain/cronos)|`v0.8.2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-cronos-v0.8.2`|[Example](./cronos)|
|[cryptoorgchain](https://github.com/crypto-org-chain/chain-main)|`v3.3.9`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-cryptoorgchain-v3.3.9`|[Example](./cryptoorgchain)|
|[decentr](https://github.com/Decentr-net/decentr)|`v1.6.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-decentr-v1.6.0`|[Example](./decentr)|
|[defund](https://github.com/defund-labs/defund)|`v0.1.0-alpha`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-defund-v0.1.0-alpha`|[Example](./defund)|
|[desmos](https://github.com/desmos-labs/desmos)|`v2.4.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-desmos-v2.4.0`|[Example](./desmos)|
|[dig](https://github.com/notional-labs/dig)|`v3.3.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-dig-v3.3.1`|[Example](./dig)|
|[emoney](https://github.com/e-money/em-ledger)|`v1.2.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-emoney-v1.2.0`|[Example](./emoney)|
|[empowerchain](https://github.com/empowerchain/empowerchain)|`v0.0.3`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-empowerchain-v0.0.3`|[Example](./empowerchain)|
|[evmos](https://github.com/evmos/evmos)|`v9.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-evmos-v9.1.0`|[Example](./evmos)|
|[fetchhub](https://github.com/fetchai/fetchd)|`v0.10.6`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-fetchhub-v0.10.6`|[Example](./fetchhub)|
|[gravitybridge](https://github.com/Gravity-Bridge/Gravity-Bridge)|`v1.7.2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-gravitybridge-v1.7.2`|[Example](./gravitybridge)|
|[impacthub](https://github.com/ixofoundation/ixo-blockchain)|`v0.18.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-impacthub-v0.18.1`|[Example](./impacthub)|
|[irisnet](https://github.com/irisnet/irishub)|`v1.3.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-irisnet-v1.3.1`|[Example](./irisnet)|
|[jackal](https://github.com/JackalLabs/canine-chain)|`v1.1.2-hotfix`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-jackal-v1.1.2-hotfix`|[Example](./jackal)|
|[juno](https://github.com/CosmosContracts/Juno)|`v11.0.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-juno-v11.0.0`|[Example](./juno)|
|[kava](https://github.com/Kava-Labs/kava)|`v0.18.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-kava-v0.18.1`|[Example](./kava)|
|[kichain](https://github.com/KiFoundation/ki-tools)|`4.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-kichain-4.1.0`|[Example](./kichain)|
|[konstellation](https://github.com/konstellation/konstellation)|`v0.5.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-konstellation-v0.5.0`|[Example](./konstellation)|
|[kujira](https://github.com/Team-Kujira/core)|`v0.7.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-kujira-v0.7.1`|[Example](./kujira)|
|[likecoin](https://github.com/likecoin/likecoin-chain)|`v3.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-likecoin-v3.1.0`|[Example](./likecoin)|
|[lumnetwork](https://github.com/lum-network/chain)|`v1.2.2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-lumnetwork-v1.2.2`|[Example](./lumnetwork)|
|[omniflixhub](https://github.com/OmniFlix/omniflixhub)|`v0.8.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-omniflixhub-v0.8.0`|[Example](./omniflixhub)|
|[osmosis](https://github.com/osmosis-labs/osmosis)|`v13.0.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-osmosis-v13.0.0`|[Example](./osmosis)|
|[panacea](https://github.com/medibloc/panacea-core)|`v2.0.5`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-panacea-v2.0.5`|[Example](./panacea)|
|[passage](https://github.com/envadiv/Passage3D)|`v1.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-passage-v1.1.0`|[Example](./passage)|
|[persistence](https://github.com/persistenceOne/persistenceCore)|`v3.2.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-persistence-v3.2.0`|[Example](./persistence)|
|[regen](https://github.com/regen-network/regen-ledger)|`v4.1.4`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-regen-v4.1.4`|[Example](./regen)|
|[rizon](https://github.com/rizon-world/rizon)|`v0.4.1`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-rizon-v0.4.1`|[Example](./rizon)|
|[seinetwork](https://github.com/sei-protocol/sei-chain)|`1.2.2beta-postfix`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-seinetwork-1.2.2beta-postfix`|[Example](./seinetwork)|
|[sentinel](https://github.com/sentinel-official/hub)|`v0.9.3`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-sentinel-v0.9.3`|[Example](./sentinel)|
|[shentu](https://github.com/certikfoundation/shentu)|`v2.5.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-shentu-v2.5.0`|[Example](./shentu)|
|[sifchain](https://github.com/Sifchain/sifnode)|`v1.1.0-beta`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-sifchain-v1.1.0-beta`|[Example](./sifchain)|
|[sommelier](https://github.com/PeggyJV/sommelier)|`v4.0.2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-sommelier-v4.0.2`|[Example](./sommelier)|
|[stargaze](https://github.com/public-awesome/stargaze)|`v7.5.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-stargaze-v7.5.0`|[Example](./stargaze)|
|[starname](https://github.com/iov-one/starnamed)|`v0.11.5`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-starname-v0.11.5`|[Example](./starname)|
|[stride](https://github.com/Stride-Labs/stride)|`v4.0.2`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-stride-v4.0.2`|[Example](./starname)|
|[teritori](https://github.com/TERITORI/teritori-chain)|`v1.3.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-teritori-v1.3.0`|[Example](./teritori)|
|[umee](https://github.com/umee-network/umee)|`v3.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-umee-v3.1.0`|[Example](./umee)|
|[vidulum](https://github.com/vidulum/mainnet)|`v1.2.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-vidulum-v1.2.0`|[Example](./vidulum)|

### Skip MEV Support

Additional image variants are built for chains with [Skip MEV support](https://skip.money/). Use these images if you would like to enable MEV capture and protect against sandwiching and front-running.

|Project|Version|Image| |
|---|---|---|---|
|[evmos](https://github.com/evmos/evmos)|`v9.1.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-evmos-v9.1.0-skip`|[Example](./evmos)|
|[juno](https://github.com/CosmosContracts/Juno)|`v11.0.0`|`ghcr.io/ovrclk/cosmos-omnibus:v0.3.15-juno-v11.0.0-skip`|[Example](./juno)|

Note that configuration for Skip needs to be done in the configuration file currently - the ENV variable method of configuring the node doesn't work for the Skip config options.

## Example configurations

There are example files within each project subdirectory which include a sensible default configuration for each chain. Optional configuration options are commented out so you can easily enable them, and the node can be configured further using the docs below. 

### Running on Akash

See the `deploy.yml` example file in each chain directory which details the minimum configuration required. Use the [configuration options below](#configuration) to add functionality. Note the commented out persistent storage configuration if needed.

### Running locally/any docker host

See the `docker-compose.yml` example file in each chain directory to run each node using `docker-compose up`.

## Snaphots

Omnibus can [import chain snapshots](#snapshot-restore) from almost any location. Some examples are Chain Layer's [QuickSync service](https://quicksync.io) and Polkachu's [Tendermint Snapshots](https://www.polkachu.com/tendermint_snapshots).

Appropriate snapshot configuration is included in most example configurations in the Omnibus repository. Check the project directories for more information.

Akash also generate and publish snapshots for the Akash blockchain. Pruned snapshots are taken daily, and Archive snapshots weekly.

These snapshots are created using Omnibus nodes running on Akash, as shown in the [Snapshot Backup](_examples/snapshot_backup) example.

|Type|Snapshot JSON|
|---|---|
|Akash Pruned|https://cosmos-snapshots.s3.filebase.com/akash/pruned/snapshot.json|
|Akash Archive|https://cosmos-snapshots.s3.filebase.com/akash/snapshot.json|

## Examples

See the [_examples](./_examples) directory for some common setups, including:

- [Statesync](./_examples/statesync)
- [Load Balanced RPC Nodes](./_examples/load-balanced-rpc-nodes)
- [Validator and TMKMS](./_examples/validator-and-tmkms)
- [Validator and Public Sentries](./_examples/validator-and-public-sentries)
- [Validator with Private Sentries](./_examples/validator-and-private-sentries)
- [Snapshot Backup](./_examples/snapshot_backup)

## Configuration

Cosmos blockchains can be configured entirely using environment variables instead of the config files.
Every chain has it's own prefix, but the format of the configuration is the same.

For example to configure the `seeds` option in the `p2p` section of `config.toml`, for the Akash blockchain:

```
AKASH_P2P_SEEDS=id@node:26656
```

The namespace for each of the supported chains in the cosmos omnibus can be found in the `README` in each project directory.

The omnibus images allow some specific variables and shortcuts to configure extra functionality, detailed below.

### Chain configuration

Chain config can be sourced from a `chain.json` file [as seen in the Cosmos Chain Registry](https://github.com/cosmos/chain-registry).

|Variable|Description|Default|Examples|
|---|---|---|---|
|`CHAIN_JSON`|URL to a `chain.json` file detailing the chain meta| |`https://github.com/cosmos/chain-registry/blob/master/akash/chain.json`
|`CHAIN_ID`|The cosmos chain ID| |`akashnet-2`
|`GENESIS_URL`|URL to the genesis file in `.gz`, `.tar.gz`, or `.zip` format. Can be set by CHAIN_JSON| |`https://raw.githubusercontent.com/ovrclk/net/master/mainnet/genesis.json`
|`DOWNLOAD_GENESIS`|Force download of genesis file. If unset the node will only download if the genesis file is missing| |`1`|
|`VALIDATE_GENESIS`|Set to 1 to enable validation of genesis file|`0`|`1`

### P2P

Peer information can be provided manually, or obtained automatically from the following sources:

- `CHAIN_JSON` URL with peer information included.
- [Polkachu's live peers](https://www.polkachu.com/live_peers).
- Any `ADDRBOOK_URL` where the `config/addrbook.json` file is hosted.

See [Cosmos docs](https://docs.tendermint.com/master/nodes/configuration.html#p2p-settings) for more information.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`P2P_SEEDS`|Seed nodes. Can be set by CHAIN_JSON or GENESIS_URL| |`id@node:26656`|
|`P2P_PERSISTENT_PEERS`|Persistent peers. Can be set by CHAIN_JSON or GENESIS_URL| |`id@node:26656`|
|`P2P_POLKACHU`|Import live persistent peers from [Polkachu](https://www.polkachu.com/live_peers) if available| |`1`|
|`ADDRBOOK_URL`|URL to an addrbook.json file| |`https://quicksync.io/addrbook.terra.json`

### Private key backup/restore

On boot, the container can restore a private key from any S3 storage provider. If this is configured and the key doesn't exist in S3 yet, it will be uploaded from the node.

This allows for a persistent node ID and validator key on Akash's ephemeral storage.

[Filebase](https://filebase.com/) is a great way to use S3 with decentralised hosting such as Sia.

The `node_key.json` and `priv_validator_key.json` are both backed up, and can be encrypted with a password.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`S3_KEY`|S3 access key| | |
|`S3_SECRET`|S3 secret key| | |
|`S3_HOST`|The S3 API host|`https://s3.filebase.com`|`https://s3.us-east-1.amazonaws.com`|
|`KEY_PATH`|Bucket and directory to backup/restore to| |`bucket/nodes/node_1`|
|`KEY_PASSWORD`|An optional password to encrypt your private keys. Shouldn't be optional| | |

### Statesync

Some shortcuts for enabling statesync. Statesync requires 2x nodes with snapshots enabled.

Statesync nodes can also be sourced from [Polkachu's Statesync service](https://www.polkachu.com/state_sync) automatically.

[See an example](_examples/statesync) of a statesync deployment.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`STATESYNC_SNAPSHOT_INTERVAL`|Take a snapshot to provide statesync every X blocks| |`500`|
|`STATESYNC_ENABLE`|Enabling statesyncing from a node. Default `true` if `STATESYNC_RPC_SERVERS` is set| | |
|`STATESYNC_RPC_SERVERS`|Comma separated list of RPC nodes with snapshots enabled| |`ip:26657,ip2:26657`|
|`STATESYNC_TRUSTED_NODE`|A trusted node to obtain trust height and hash from. Defaults to the first `STATESYNC_RPC_SERVERS` if set| |`ip:26657`|
|`STATESYNC_TRUST_PERIOD`|Trust period for the statesync snapshot|`168h0m0s`| |
|`STATESYNC_TRUST_HEIGHT`|Obtained from `STATESYNC_TRUSTED_NODE`| | |
|`STATESYNC_TRUST_HASH`|Obtained from `STATESYNC_TRUSTED_NODE`| | |
|`STATESYNC_POLKACHU`|Import [Polkachu's](https://www.polkachu.com/state_sync) statesync addresses if available| |`1`|

### Snapshot restore

The node `data` directory can be restored from a `.tar`, `.tar.gz` or `.lz4` file stored on a public URL.
The file can be obtained from the following sources:

- Direct URL to the archive file
- Base URL file listing, where the archive matches a given pattern.
- [snapshot.json](#snapshot-backup) generated by [Omnibus Snapshot backup](#snapshot-backup) feature.
- ChainLayer's [Quicksync snapshots](https://quicksync.io/) described by a JSON file.
- Polkachu's [snapshot service](https://www.polkachu.com/tendermint_snapshots), fully automatically.

Note that snapshots will be restored in-process, without downloading the snapshot to disk first. This saves disk space but is slower to extract, and could be made configurable in the future.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`DOWNLOAD_SNAPSHOT`|Force bootstrapping from snapshot. If unset the node will only restore a snapshot if the `data` contents are missing| |`1`|
|`SNAPSHOT_URL`|A URL to a `.tar`, `.tar.gz` or `.lz4` file| |`http://135.181.60.250/akash/akashnet-2_2021-06-16.tar`|
|`SNAPSHOT_BASE_URL`|A base URL to a directory containing backup files| |`http://135.181.60.250/akash`|
|`SNAPSHOT_JSON`|A URL to a `snapshot.json` as detailed in [Snapshot backup](#snapshot-backup)| |`https://cosmos-snapshots.s3.filebase.com/akash/pruned/snapshot.json`|
|`SNAPSHOT_FORMAT`|The format of the snapshot file|`tar.gz`|`tar`/`tar.zst`|
|`SNAPSHOT_PATTERN`|The pattern of the file in the `SNAPSHOT_BASE_URL`|`$CHAIN_ID.*$SNAPSHOT_FORMAT`|`foobar.*tar.gz`|
|`SNAPSHOT_DATA_PATH`|The path to the data directory within the archive| |`snapshot/data`|
|`SNAPSHOT_WASM_PATH`|The path to the wasm directory within the archive, if exists outside of data| |`snapshot/wasm`|
|`SNAPSHOT_PRUNING`|Type of snapshot to download, e.g. `archive`, `pruned`, `default`.|`pruned`|`archive`|
|`SNAPSHOT_QUICKSYNC`|A URL to a Quicksync JSON file describing their snapshots. Also see `SNAPSHOT_PRUNING`| |`https://quicksync.io/terra.json`|
|`SNAPSHOT_POLKACHU`|Import [Polkachu's](https://www.polkachu.com/tendermint_snapshots) snapshot automatically if available| |`1`|

### Snapshot backup

Omnibus includes a script to automatically snapshot a node and upload the resulting archive to any S3 compatible service like [Filebase](https://filebase.com/).
At a specified time (or day), the script will shut down the tendermint server, create an archive of the `data` directory and upload it.
Snapshots older than a specified time can also be deleted. Finally a JSON metadata file is created listing the current snapshots. The server is then restarted and monitored.

[See an example](_examples/snapshot_backup) of a snapshot node deployment.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`S3_KEY`|S3 access key| | |
|`S3_SECRET`|S3 secret key| | |
|`S3_HOST`|The S3 API host|`https://s3.filebase.com`|`s3.us-east-1.amazonaws.com`|
|`SNAPSHOT_PATH`|The S3 path to upload snapshots to, including the bucket| |`cosmos-snapshots/akash`|
|`SNAPSHOT_PREFIX`|The prefix for the snapshot filename|`$CHAIN_ID`|`snapshot`|
|`SNAPSHOT_TIME`|The time the snapshot will run|`00:00:00`|`09:00:00`|
|`SNAPSHOT_DAY`|The numeric day of the week the snapshot will run (Monday = 1)|`*`|`7`|
|`SNAPSHOT_DIR`|The directory on disk to snapshot|`$PROJECT_ROOT/data`|`/root/.akash`|
|`SNAPSHOT_CMD`|The command to run the server|`$START_CMD`|`akash start --someflag`|
|`SNAPSHOT_RETAIN`|How long to retain snapshots for (0 to disable)|`2 days`|`1 week`|
|`SNAPSHOT_METADATA`|Whether to create a snapshot.json metadata file|`1`|`0`|
|`SNAPSHOT_METADATA_URL`|The URL snapshots will be served from (for snapshot.json)| |`https://cosmos-snapshots.s3.filebase.com/akash`|
|`SNAPSHOT_SAVE_FORMAT`|Overrides value from `SNAPSHOT_FORMAT`.|`tar.gz`|`tar` (no compression)/`tar.zst` (use [zstd](https://github.com/facebook/zstd))|

When `SNAPSHOT_SAVE_FORMAT` is set to `tar.zst`, [additional variables can be set](https://github.com/facebook/zstd/tree/v1.5.2/programs#passing-parameters-through-environment-variables):
- `ZSTD_CLEVEL` - Compression level, default `3`
- `ZSTD_NBTHREADS` - No. of threads, default `1`, `0` = detected no. of cpu cores

### Binary download

The node binary can be downloaded at runtime when using the [Generic image](#generic-image-binary-downloaded-at-runtime). All configuration can be sourced from `CHAIN_JSON` if the attributes are available, or configured manually. You will need to set `PROJECT`, `PROJECT_BIN` and `PROJECT_DIR` if these can't be sourced from `CHAIN_JSON`.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`BINARY_URL`|URL to the binary (or `zip`, `tar`, `tar.gz`)| | |
|`BINARY_ZIP_PATH`|Path to the binary in the archive. Can be left blank if correctly named in root| | |
|`PROJECT`|Name of the project, informs other variables| | |
|`PROJECT_BIN`|Binary name|`$PROJECT`|`osmosisd`|
|`PROJECT_DIR`|Name of project directory|`.$PROJECT_BIN`|`.osmosisd`|

### Shortcuts

See [Cosmos docs](https://docs.tendermint.com/master/nodes/configuration.html) for more information

|Variable|Description|Default|Examples|
|---|---|---|---|
|`FASTSYNC_VERSION`|The fastsync version| |`v0`|
|`MINIMUM_GAS_PRICES`|Minimum gas prices| |`0.025uakt`|
|`PRUNING`|How much of the chain to prune| |`nothing`|
|`DEBUG`|Set to `1` to output all environment variables on boot. Set to `2` to debug shell scripts.| |`1`, `2`|

## Contributing

Adding a new chain is easy:

- Ideally source or setup a `chain.json` to provide a single source of truth for chain info
- Add a project directory based on the existing projects
- Update the [github workflow](https://github.com/ovrclk/cosmos-omnibus/blob/master/.github/workflows/publish.yaml) to create an image for your chain

Submit a PR or an issue if you want to see any specific chains.
