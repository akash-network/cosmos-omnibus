# COSMOS OMNIBUS - Run Cosmos Nodes on Akash

This is a meta package of [cosmos-sdk](https://github.com/cosmos/cosmos-sdk)-based
docker images and configuration meant to make deploying onto [Akash](//github.com/akash-network/node)
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

Image URL: `ghcr.io/akash-network/cosmos-omnibus:v0.4.5-generic`

```yaml
services:
  node:
    image: ghcr.io/akash-network/cosmos-omnibus:v0.4.5-generic
    env:
      - MONIKER=my-moniker-1
      - CHAIN_JSON=https://raw.githubusercontent.com/akash-network/net/main/edgenet/meta.json
      - BINARY_ZIP_PATH=akash_0.15.0-rc14_linux_amd64/akash
```

More information on the generic image can be found at [/generic](./generic/), and configuration is detailed in depth below.

## Networks (pre-built images)

The available docker images can be found [here](https://github.com/orgs/akash-network/packages/container/package/cosmos-omnibus).  They are
tagged with the form `$COSMOS_OMNIBUS_VERSION-$PROJECT-$PROJECT_VERSION`.

|Project|Version|Image| |
|---|---|---|---|
|[agoric](https://github.com/Agoric/ag0)|`agoric-upgrade-7-2`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-agoric-agoric-upgrade-7-2`|[Example](./agoric)|
|[akash](https://github.com/akash-network/node)|`v0.30.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-akash-v0.30.0`|[Example](./akash)|
|[archway](https://github.com/archway-network/archway)|`v4.0.2`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-archway-v4.0.2`|[Example](./archway)|
|[assetmantle](https://github.com/AssetMantle/node)|`v1.0.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-assetmantle-v1.0.0`|[Example](./assetmantle)|
|[autonomy](https://github.com/AutonomyNetwork/autonomy-chain)|`v1.2.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-autonomy-v1.2.1`|[Example](./autonomy)|
|[axelar](https://github.com/axelarnetwork/axelar-core)|`v0.34.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-axelar-v0.34.0`|[Example](./axelar)|
|[bandchain](https://github.com/bandprotocol/chain)|`v2.5.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-bandchain-v2.5.1`|[Example](./bandchain)|
|[bitcanna](https://github.com/BitCannaGlobal/bcna)|`v2.0.3`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-bitcanna-v2.0.3`|[Example](./bitcanna)|
|[bitsong](https://github.com/bitsongofficial/go-bitsong)|`v0.14.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-bitsong-v0.14.0`|[Example](./bitsong)|
|[bostrom](https://github.com/cybercongress/go-cyber)|`v0.3.2`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-bostrom-v0.3.2`|[Example](./bostrom)|
|[canto](https://github.com/Canto-Network/Canto)|`v7.0.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-canto-v7.0.0`|[Example](./canto)|
|[cheqd](https://github.com/cheqd/cheqd-node)|`0.6.9`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-cheqd-0.6.9`|[Example](./cheqd)|
|[chihuahua](https://github.com/ChihuahuaChain/chihuahua)|`v6.0.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-chihuahua-v6.0.1`|[Example](./chihuahua)|
|[comdex](https://github.com/comdex-official/comdex)|`v13.4.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-comdex-v13.4.0`|[Example](./comdex)|
|[cosmoshub](https://github.com/cosmos/gaia)|`v14.1.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-cosmoshub-v14.1.0`|[Example](./cosmoshub)|
|[crescent](https://github.com/crescent-network/crescent)|`v4.2.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-crescent-v4.2.0`|[Example](./crescent)|
|[cronos](https://github.com/crypto-org-chain/cronos)|`v1.0.9`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-cronos-v1.0.9`|[Example](./cronos)|
|[cryptoorgchain](https://github.com/crypto-org-chain/chain-main)|`v4.2.8`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-cryptoorgchain-v4.2.8`|[Example](./cryptoorgchain)|
|[decentr](https://github.com/Decentr-net/decentr)|`v1.6.4`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-decentr-v1.6.4`|[Example](./decentr)|
|[defund](https://github.com/defund-labs/defund)|`v0.1.0-alpha`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-defund-v0.1.0-alpha`|[Example](./defund)|
|[desmos](https://github.com/desmos-labs/desmos)|`v6.2.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-desmos-v6.2.0`|[Example](./desmos)|
|[dig](https://github.com/notional-labs/dig)|`v3.3.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-dig-v3.3.1`|[Example](./dig)|
|[dydx](https://github.com/dydxprotocol/v4-chain)|`v2.0.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-dydx-v2.0.0`|[Example](./dydx)|
|[emoney](https://github.com/e-money/em-ledger)|`v1.2.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-emoney-v1.2.0`|[Example](./emoney)|
|[empowerchain](https://github.com/empowerchain/empowerchain)|`v2.0.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-empowerchain-v2.0.0`|[Example](./empowerchain)|
|[evmos](https://github.com/evmos/evmos)|`v16.0.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-evmos-v16.0.1`|[Example](./evmos)|
|[fetchhub](https://github.com/fetchai/fetchd)|`v0.10.6`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-fetchhub-v0.10.6`|[Example](./fetchhub)|
|[gitopia](https://github.com/gitopia/gitopia)|`v2.1.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-gitopia-v2.1.1`|[Example](./gitopia)|
|[gravitybridge](https://github.com/Gravity-Bridge/Gravity-Bridge)|`v1.11.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-gravitybridge-v1.11.1`|[Example](./gravitybridge)|
|[impacthub](https://github.com/ixofoundation/ixo-blockchain)|`v0.18.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-impacthub-v0.18.1`|[Example](./impacthub)|
|[injective](https://github.com/InjectiveLabs/injective-chain-releases)|`v1.12.0-1704530206`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-injective-v1.12.0-1704530206`|[Example](./injective)|
|[irisnet](https://github.com/irisnet/irishub)|`v2.0.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-irisnet-v2.0.1`|[Example](./irisnet)|
|[jackal](https://github.com/JackalLabs/canine-chain)|`v3.0.5`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-jackal-v3.0.5`|[Example](./jackal)|
|[juno](https://github.com/CosmosContracts/Juno)|`v18.1.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-juno-v18.1.0`|[Example](./juno)|
|[kava](https://github.com/Kava-Labs/kava)|`v0.25.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-kava-v0.25.0`|[Example](./kava)|
|[kichain](https://github.com/KiFoundation/ki-tools)|`5.0.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-kichain-5.0.1`|[Example](./kichain)|
|[konstellation](https://github.com/konstellation/konstellation)|`v0.5.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-konstellation-v0.5.0`|[Example](./konstellation)|
|[kujira](https://github.com/Team-Kujira/core)|`v0.9.3-1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-kujira-v0.9.3-1`|[Example](./kujira)|
|[kyve](https://github.com/KYVENetwork/chain)|`v1.4.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-kyve-v1.4.0`|[Example](./kyve)|
|[likecoin](https://github.com/likecoin/likecoin-chain)|`v4.1.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-likecoin-v4.1.1`|[Example](./likecoin)|
|[lumnetwork](https://github.com/lum-network/chain)|`v1.6.3`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-lumnetwork-v1.6.3`|[Example](./lumnetwork)|
|[mars](https://github.com/mars-protocol/hub.git)|`v1.0.2`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-mars-v1.0.2`|[Example](./mars)|
|[migaloo](https://github.com/White-Whale-Defi-Platform/migaloo-chain)|`v3.0.2`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-migaloo-v3.0.2`|[Example](./migaloo)|
|[neutron](https://github.com/neutron-org/neutron)|`v2.0.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-neutron-v2.0.1`|[Example](./neutron)|
|[nois](https://github.com/noislabs/noisd)|`v1.0.4`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-nois-v1.0.4`|[Example](./nois)|
|[omniflixhub](https://github.com/OmniFlix/omniflixhub)|`v0.12.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-omniflixhub-v0.12.1`|[Example](./omniflixhub)|
|[osmosis](https://github.com/osmosis-labs/osmosis)|`v21.2.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-osmosis-v21.2.1`|[Example](./osmosis)|
|[panacea](https://github.com/medibloc/panacea-core)|`v2.0.5`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-panacea-v2.0.5`|[Example](./panacea)|
|[passage](https://github.com/envadiv/Passage3D)|`v2.3.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-passage-v2.3.0`|[Example](./passage)|
|[persistence](https://github.com/persistenceOne/persistenceCore)|`v10.2.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-persistence-v10.2.0`|[Example](./persistence)|
|[regen](https://github.com/regen-network/regen-ledger)|`v5.1.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-regen-v5.1.1`|[Example](./regen)|
|[rizon](https://github.com/rizon-world/rizon)|`v0.4.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-rizon-v0.4.1`|[Example](./rizon)|
|[seinetwork](https://github.com/sei-protocol/sei-chain)|`1.2.2beta-postfix`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-seinetwork-1.2.2beta-postfix`|[Example](./seinetwork)|
|[sentinel](https://github.com/sentinel-official/hub)|`v0.11.3`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-sentinel-v0.11.3`|[Example](./sentinel)|
|[shentu](https://github.com/certikfoundation/shentu)|`v2.9.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-shentu-v2.9.0`|[Example](./shentu)|
|[sifchain](https://github.com/Sifchain/sifnode)|`v1.4.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-sifchain-v1.4.0`|[Example](./sifchain)|
|[sommelier](https://github.com/PeggyJV/sommelier)|`v4.0.2`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-sommelier-v4.0.2`|[Example](./sommelier)|
|[stargaze](https://github.com/public-awesome/stargaze)|`v12.0.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-stargaze-v12.0.0`|[Example](./stargaze)|
|[starname](https://github.com/iov-one/starnamed)|`v0.11.5`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-starname-v0.11.5`|[Example](./starname)|
|[stride](https://github.com/Stride-Labs/stride)|`v16.0.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-stride-v16.0.0`|[Example](./stride)|
|[teritori](https://github.com/TERITORI/teritori-chain)|`v1.4.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-teritori-v1.4.0`|[Example](./teritori)|
|[umee](https://github.com/umee-network/umee)|`v6.3.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-umee-v6.3.0`|[Example](./umee)|
|[ununifi](https://github.com/UnUniFi/chain)|`v4.0.1`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-ununifi-v4.0.1`|[Example](./ununifi)|
|[vidulum](https://github.com/vidulum/mainnet)|`v1.2.0`|`ghcr.io/akash-network/cosmos-omnibus:v0.4.5-vidulum-v1.2.0`|[Example](./vidulum)|

## Example configurations

There are example files within each project subdirectory which include a sensible default configuration for each chain. Optional configuration options are commented out so you can easily enable them, and the node can be configured further using the docs below.

### Running on Akash

See the `deploy.yml` example file in each chain directory which details the minimum configuration required. Use the [configuration options below](#configuration) to add functionality. Note the commented out persistent storage configuration if needed.

### Running locally/any docker host

See the `docker-compose.yml` example file in each chain directory to run each node using `docker-compose up`.

## Snapshots

Omnibus can [import chain snapshots](#snapshot-restore) from almost any location. Some examples are Chain Layer's [QuickSync service](https://quicksync.io) and Polkachu's [Tendermint Snapshots](https://www.polkachu.com/tendermint_snapshots).

Appropriate snapshot configuration is included in most example configurations in the Omnibus repository. Check the project directories for more information.

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
Every chain has its own prefix, but the format of the configuration is the same.

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
|`GENESIS_URL`|URL to the genesis file in `.gz`, `.tar.gz`, or `.zip` format. Can be set by CHAIN_JSON| |`https://raw.githubusercontent.com/akash-network/net/main/mainnet/genesis.json`
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
|`STORJ_ACCESS_GRANT`|DCS Storj Access Grant token (replaces `S3_KEY`, `S3_SECRET`, `S3_HOST`| | |
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
|`STORJ_ACCESS_GRANT`|DCS Storj Access Grant token (replaces `S3_KEY`, `S3_SECRET`, `S3_HOST`| | |
|`STORJ_UPLINK_ARGS`|DCS Storj Uplink arguments|`-p 4 --progress=false`|`-p 4 --parallelism-chunk-size 256M --progress=false`|
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

### Polkachu Services

[Polkachu](https://polkachu.com/) validator provides various Cosmos chain services that can be automatically enabled using environment variables.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`POLKACHU_CHAIN_ID`| Polkachu API chain-id if it differs from Chain Registry naming convention.| |`cryptocom`
|`P2P_POLKACHU`|Import [Polkachu's](https://www.polkachu.com/seeds) seed node if available| |`1`|
|`STATESYNC_POLKACHU`|Import [Polkachu's](https://www.polkachu.com/state_sync) statesync addresses if available| |`1`|

### Cosmovisor

[Cosmovisor](https://docs.cosmos.network/main/tooling/cosmovisor) can be downloaded at runtime to automatically manage chain upgrades. You should be familiar with how Cosmovisor works before using this feature.

|Variable|Description|Default|Examples|
|---|---|---|---|
|`COSMOVISOR_ENABLED`|Enable Cosmovisor binary download and support| |`1`|
|`COSMOVISOR_VERSION`|Version of Cosmovisor to download|`1.5.0`| |
|`COSMOVISOR_URL`|Alternative full URL to Cosmovisor binary tar.gz| | |

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
- Update the [github workflow](https://github.com/akash-network/cosmos-omnibus/blob/master/.github/workflows/publish.yaml) to create an image for your chain

Submit a PR or an issue if you want to see any specific chains.
