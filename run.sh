#!/bin/bash

set -e

[ "$DEBUG" == "2" ] && set -x

export CHAIN_JSON="${CHAIN_JSON:-$CHAIN_URL}" # deprecate CHAIN_URL
if [[ -z "$CHAIN_JSON" && -n "$PROJECT" ]]; then
  CHAIN_JSON="https://raw.githubusercontent.com/cosmos/chain-registry/master/${PROJECT}/chain.json"
fi

CHAIN_JSON_EXISTS=false
if [[ -n "$CHAIN_JSON" && "$CHAIN_JSON" != "0" ]]; then
  if curl --output /dev/null --silent --head --fail "$CHAIN_JSON"; then
    CHAIN_JSON_EXISTS=true
  else
    echo "Chain JSON not found"
  fi
fi
if [[ $CHAIN_JSON_EXISTS == true ]]; then
  sleep 0.5 # avoid rate limiting
  CHAIN_METADATA=$(curl -Ls $CHAIN_JSON)
  CHAIN_SEEDS=$(echo $CHAIN_METADATA | jq -r '.peers.seeds | map(.id+"@"+.address) | join(",")')
  CHAIN_PERSISTENT_PEERS=$(echo $CHAIN_METADATA | jq -r '.peers.persistent_peers | map(.id+"@"+.address) | join(",")')

  export CHAIN_ID="${CHAIN_ID:-$(echo $CHAIN_METADATA | jq -r .chain_id)}"
  export GENESIS_URL="${GENESIS_URL:-$(echo $CHAIN_METADATA | jq -r '.codebase.genesis.genesis_url? // .genesis.genesis_url? // .genesis?')}"
  export BINARY_URL="${BINARY_URL:-$(echo $CHAIN_METADATA | jq -r '.codebase.binaries."linux/amd64"?')}"
  export PROJECT="${PROJECT:-$(echo $CHAIN_METADATA | jq -r '.chain_name?')}"
  export PROJECT_BIN="${PROJECT_BIN:-$(echo $CHAIN_METADATA | jq -r '.codebase.daemon_name? // .daemon_name?')}"
  if [ -z "$PROJECT_DIR" ]; then
    FULL_DIR=$(echo $CHAIN_METADATA | jq -r '.codebase.node_home? // .node_home?')
    [ -n "$FULL_DIR" ] && export PROJECT_DIR=${FULL_DIR#'$HOME/'}
  fi

  if [ -z "$MINIMUM_GAS_PRICES" ]; then
    GAS_PRICES=""
    FEE_TOKENS=$(echo $CHAIN_METADATA | jq -c '.fees.fee_tokens[]? // empty')
    if [ -n "$FEE_TOKENS" ]; then
      for TOKEN in $FEE_TOKENS; do
        FEE_TOKEN=$(echo $TOKEN | jq -r '.denom // empty')
        GAS_PRICE=$(echo $TOKEN | jq -r '.fixed_min_gas_price // .low_gas_price // empty')
        if [ -n "$FEE_TOKEN" ] && [ -n "$GAS_PRICE" ]; then
          if [ -n "$GAS_PRICES" ]; then
            GAS_PRICES="$GAS_PRICES,$GAS_PRICE$FEE_TOKEN"
          else
            GAS_PRICES="$GAS_PRICE$FEE_TOKEN"
          fi
        fi
      done
      if [ -n "$GAS_PRICES" ]; then
        export MINIMUM_GAS_PRICES=$GAS_PRICES
        echo "Minimum gas prices set to $MINIMUM_GAS_PRICES"
      fi
    fi
  fi
fi

export PROJECT_BIN="${PROJECT_BIN:-$PROJECT}"
export PROJECT_DIR="${PROJECT_DIR:-.$PROJECT_BIN}"
export CONFIG_DIR="${CONFIG_DIR:-config}"
export DATA_DIR="${DATA_DIR:-data}"
export WASM_DIR="${WASM_DIR:-wasm}"
export PROJECT_ROOT="/root/$PROJECT_DIR"
export CONFIG_PATH="${CONFIG_PATH:-$PROJECT_ROOT/$CONFIG_DIR}"
export DATA_PATH="${DATA_PATH:-$PROJECT_ROOT/$DATA_DIR}"
export WASM_PATH="${WASM_PATH:-$PROJECT_ROOT/$WASM_DIR}"
export NAMESPACE="${NAMESPACE:-$(echo ${PROJECT_BIN} | tr '[:lower:]' '[:upper:]' | tr '-' '_')}"
export VALIDATE_GENESIS="${VALIDATE_GENESIS:-0}"
export MONIKER="${MONIKER:-Cosmos Omnibus Node}"

[ -z "$CHAIN_ID" ] && echo "CHAIN_ID not found" && exit

if [[ -n "$BINARY_URL" && ! -f "/bin/$PROJECT_BIN" ]]; then
  echo "Download binary $PROJECT_BIN from $BINARY_URL"
  curl -Lso /bin/$PROJECT_BIN $BINARY_URL
  file_description=$(file /bin/$PROJECT_BIN)
  case "${file_description,,}" in
    *"gzip compressed data"*)   mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.tgz && tar -xvf /bin/$PROJECT_BIN.tgz -C /bin && rm /bin/$PROJECT_BIN.tgz;;
    *"tar archive"*)            mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.tar && tar -xf /bin/$PROJECT_BIN.tar -C /bin && rm /bin/$PROJECT_BIN.tar;;
    *"zip archive data"*)       mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.zip && unzip /bin/$PROJECT_BIN.zip -d /bin && rm /bin/$PROJECT_BIN.zip;;
  esac
  [ -n "$BINARY_ZIP_PATH" ] && mv /bin/${BINARY_ZIP_PATH} /bin/$PROJECT_BIN
  chmod +x /bin/$PROJECT_BIN

  if [ -n "$WASMVM_URL" ]; then
    WASMVM_PATH="${WASMVM_PATH:-/lib/libwasmvm.so}"
    echo "Downloading wasmvm from $WASMVM_URL..."
    curl -Ls $WASMVM_URL > $WASMVM_PATH
  fi
fi

export AWS_ACCESS_KEY_ID=$S3_KEY
export AWS_SECRET_ACCESS_KEY=$S3_SECRET
export S3_HOST="${S3_HOST:-https://s3.filebase.com}"
export STORJ_ACCESS_GRANT=$STORJ_ACCESS_GRANT

storj_args="${STORJ_UPLINK_ARGS:--p 4 --progress=false}"

if [ -n "$STORJ_ACCESS_GRANT" ]; then
  uplink access import --force --interactive=false default "$STORJ_ACCESS_GRANT"
fi

if [ -n "$KEY_PATH" ]; then
  s3_uri_base="s3://${KEY_PATH%/}"
  storj_uri_base="sj://${KEY_PATH%/}"
  aws_args="--endpoint-url ${S3_HOST}"
  if [ -n "$KEY_PASSWORD" ]; then
    file_suffix=".gpg"
  else
    file_suffix=""
  fi
fi

restore_key () {
  if [ -n "$STORJ_ACCESS_GRANT" ]; then
    existing=$(uplink ls "${storj_uri_base}/$1" | head -n 1)
  else
    existing=$(aws $aws_args s3 ls "${s3_uri_base}/$1" | head -n 1)
  fi
  if [[ -z $existing ]]; then
    echo "$1 backup not found"
  else
    echo "Restoring $1"
    if [ -n "$STORJ_ACCESS_GRANT" ]; then
      uplink cp "${storj_uri_base}/$1" $CONFIG_PATH/$1$file_suffix
    else
      aws $aws_args s3 cp "${s3_uri_base}/$1" $CONFIG_PATH/$1$file_suffix
    fi

    if [ -n "$KEY_PASSWORD" ]; then
      echo "Decrypting"
      gpg --decrypt --batch --passphrase "$KEY_PASSWORD" $CONFIG_PATH/$1$file_suffix > $CONFIG_PATH/$1
      rm $CONFIG_PATH/$1$file_suffix
    fi
  fi
}

backup_key () {
  if [ -n "$STORJ_ACCESS_GRANT" ]; then
    existing=$(uplink ls "${storj_uri_base}/$1" | head -n 1)
  else
    existing=$(aws $aws_args s3 ls "${s3_uri_base}/$1" | head -n 1)
  fi
  if [[ -z $existing ]]; then
    echo "Backing up $1"
    if [ -n "$KEY_PASSWORD" ]; then
      echo "Encrypting backup..."
      gpg --symmetric --batch --passphrase "$KEY_PASSWORD" $CONFIG_PATH/$1
    fi
    if [ -n "$STORJ_ACCESS_GRANT" ]; then
      uplink cp $CONFIG_PATH/$1$file_suffix "${storj_uri_base}/$1"
    else
      aws $aws_args s3 cp $CONFIG_PATH/$1$file_suffix "${s3_uri_base}/$1"
    fi
    [ -n "$KEY_PASSWORD" ] && rm $CONFIG_PATH/$1.gpg
  fi
}

# Config
export "${NAMESPACE}_RPC_LADDR"="${RPC_LADDR:-tcp://0.0.0.0:26657}"
export "${NAMESPACE}_MONIKER"="$MONIKER"
[ -n "$FASTSYNC_VERSION" ] && export "${NAMESPACE}_FASTSYNC_VERSION"=$FASTSYNC_VERSION
[ -n "$MINIMUM_GAS_PRICES" ] && export "${NAMESPACE}_MINIMUM_GAS_PRICES"=$MINIMUM_GAS_PRICES
[ -n "$PRUNING" ] && export "${NAMESPACE}_PRUNING"=$PRUNING
[ -n "$PRUNING_INTERVAL" ] && export "${NAMESPACE}_PRUNING_INTERVAL"=$PRUNING_INTERVAL
[ -n "$PRUNING_KEEP_EVERY" ] && export "${NAMESPACE}_PRUNING_KEEP_EVERY"=$PRUNING_KEEP_EVERY
[ -n "$PRUNING_KEEP_RECENT" ] && export "${NAMESPACE}_PRUNING_KEEP_RECENT"=$PRUNING_KEEP_RECENT
[ -n "$DOUBLE_SIGN_CHECK_HEIGHT" ] && export "${NAMESPACE}_CONSENSUS_DOUBLE_SIGN_CHECK_HEIGHT"=$DOUBLE_SIGN_CHECK_HEIGHT

# Polkachu
if [[ -n "$STATESYNC_POLKACHU" || -n "$P2P_POLKACHU" || -n "$P2P_SEEDS_POLKACHU" || -n "$P2P_PEERS_POLKACHU" || -n "$ADDRBOOK_POLKACHU" ]]; then
  export POLKACHU_CHAIN_ID="${POLKACHU_CHAIN_ID:-$PROJECT}"
  POLKACHU_CHAIN=`curl -Ls https://polkachu.com/api/v2/chains/$POLKACHU_CHAIN_ID | jq .`
  POLKACHU_SUCCESS=$(echo $POLKACHU_CHAIN | jq -r '.success')
  if [ $POLKACHU_SUCCESS = false ]; then
    echo "Polkachu chain not recognised (POLKACHU_CHAIN_ID might need to be set)"
    exit
  else
    [ "$DEBUG" == "1" ] && echo $POLKACHU_CHAIN
    # Polkachu statesync
    if [ -n "$STATESYNC_POLKACHU" ]; then
      POLKACHU_STATESYNC_ENABLED=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.state_sync.active')
      if [ $POLKACHU_STATESYNC_ENABLED = true ]; then
        export POLKACHU_RPC_SERVER=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.state_sync.node')
        export STATESYNC_RPC_SERVERS="$POLKACHU_RPC_SERVER,$POLKACHU_RPC_SERVER"
        echo "Configured Polkachu statesync"
      else
        echo "Polkachu statesync is not active for this chain"
      fi
    fi

    # Polkachu seed
    if [ "$P2P_POLKACHU" == "1" ]; then
      export P2P_SEEDS_POLKACHU="1"
      export P2P_PEERS_POLKACHU="1"
    fi

    if [ "$P2P_SEEDS_POLKACHU" == "1" ]; then
      POLKACHU_SEED_ENABLED=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.seed.active')
      if [ $POLKACHU_SEED_ENABLED ]; then
        POLKACHU_SEED=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.seed.seed')
        if [ -n "$P2P_SEEDS" ] && ["$P2P_SEEDS" != "0"]; then
          export P2P_SEEDS="$POLKACHU_SEED,$P2P_SEEDS"
        else
          export P2P_SEEDS="$POLKACHU_SEED"
        fi
        echo "Configured Polkachu seed"
      else
        echo "Polkachu seed is not active for this chain"
      fi
    fi

    if [ "$P2P_PEERS_POLKACHU" == "1" ]; then
      POLKACHU_PEERS_ENABLED=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.live_peers.active')
      if [ $POLKACHU_PEERS_ENABLED ]; then
        POLKACHU_PEERS=`curl -Ls https://polkachu.com/api/v2/chains/$POLKACHU_CHAIN_ID/live_peers | jq .`
        POLKACHU_PEER=$(echo $POLKACHU_PEERS | jq -r '.polkachu_peer')
        POLKACHU_LIVE_PEERS=$(echo $POLKACHU_PEERS | jq -r '.live_peers | join(",")')
        if [ -n "$P2P_PERSISTENT_PEERS" ] && ["$P2P_PERSISTENT_PEERS" != "0"]; then
          export P2P_PERSISTENT_PEERS="$POLKACHU_PEER,$POLKACHU_LIVE_PEERS,$P2P_PERSISTENT_PEERS"
        else
          export P2P_PERSISTENT_PEERS="$POLKACHU_PEER,$POLKACHU_LIVE_PEERS"
        fi
        echo "Configured Polkachu live peers"
      else
        echo "Polkachu live peers is not active for this chain"
      fi
    fi

    if [ "$ADDRBOOK_POLKACHU" == "1" ]; then
      POLKACHU_ADDRBOOK_ENABLED=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.addrbook.active')
      if [ $POLKACHU_ADDRBOOK_ENABLED ]; then
        POLKACHU_ADDRBOOK=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.addrbook.download_url')
        export ADDRBOOK_URL="${ADDRBOOK_URL:-$POLKACHU_ADDRBOOK}"
      else
        echo "Polkachu addrbook is not active for this chain"
      fi
    fi
  fi
fi

[ -z "$P2P_SEEDS" ] && [ -n "$CHAIN_SEEDS" ] && export P2P_SEEDS=$CHAIN_SEEDS
[ -z "$P2P_PERSISTENT_PEERS" ] && [ -n "$CHAIN_PERSISTENT_PEERS" ] && export P2P_PERSISTENT_PEERS=$CHAIN_PERSISTENT_PEERS

# Peers
[ -n "$P2P_SEEDS" ] && [ "$P2P_SEEDS" != '0' ] && export "${NAMESPACE}_P2P_SEEDS=${P2P_SEEDS}"
[ -n "$P2P_PERSISTENT_PEERS" ] && [ "$P2P_PERSISTENT_PEERS" != '0' ] && export "${NAMESPACE}_P2P_PERSISTENT_PEERS"=${P2P_PERSISTENT_PEERS}

# Statesync
if [ -n "$STATESYNC_SNAPSHOT_INTERVAL" ]; then
  export "${NAMESPACE}_STATE_SYNC_SNAPSHOT_INTERVAL=$STATESYNC_SNAPSHOT_INTERVAL"
fi

if [ -n "$STATESYNC_RPC_SERVERS" ]; then
  export "${NAMESPACE}_STATESYNC_ENABLE=${STATESYNC_ENABLE:-true}"
  export "${NAMESPACE}_STATESYNC_RPC_SERVERS=$STATESYNC_RPC_SERVERS"
  IFS=',' read -ra rpc_servers <<< "$STATESYNC_RPC_SERVERS"
  STATESYNC_TRUSTED_NODE=${STATESYNC_TRUSTED_NODE:-${rpc_servers[0]}}
  if [ -n "$STATESYNC_TRUSTED_NODE" ]; then
    LATEST_HEIGHT=$(curl -Ls $STATESYNC_TRUSTED_NODE/block | jq -r .result.block.header.height)
    BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000))
    TRUST_HASH=$(curl -Ls "$STATESYNC_TRUSTED_NODE/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
    export "${NAMESPACE}_STATESYNC_TRUST_HEIGHT=${STATESYNC_TRUST_HEIGHT:-$BLOCK_HEIGHT}"
    export "${NAMESPACE}_STATESYNC_TRUST_HASH=${STATESYNC_TRUST_HASH:-$TRUST_HASH}"
    export "${NAMESPACE}_STATESYNC_TRUST_PERIOD=${STATESYNC_TRUST_PERIOD:-168h0m0s}"
  fi
fi

if [[ -z $DOWNLOAD_SNAPSHOT && ( -n $SNAPSHOT_URL || -n $SNAPSHOT_BASE_URL || -n $SNAPSHOT_JSON || -n $SNAPSHOT_QUICKSYNC ) && ! -f "$PROJECT_ROOT/data/priv_validator_state.json" ]]; then
  export DOWNLOAD_SNAPSHOT="1"
fi

if [[ -z $DOWNLOAD_GENESIS && -n $GENESIS_URL && ! -f "$CONFIG_PATH/genesis.json" ]]; then
  export DOWNLOAD_GENESIS="1"
fi

if [[ -z $INIT_CONFIG && ! -d "$CONFIG_PATH" ]]; then
  export INIT_CONFIG="1"
fi

[ "$DEBUG" == "1" ] && printenv

# Initialise
if [ "$INIT_CONFIG" == "1" ]; then
  if [ -n "$INIT_CMD" ]; then
    $INIT_CMD
  else
    $PROJECT_BIN init "$MONIKER" --chain-id ${CHAIN_ID}
  fi
fi

# Overwrite seeds in config.toml for chains that are not using the env variable correctly
if [ "$OVERWRITE_SEEDS" == "1" ]; then
    sed -i "s/seeds = \"\"/seeds = \"$P2P_SEEDS\"/" $CONFIG_PATH/config.toml
fi

# Restore keys
if [ -n "$KEY_PATH" ]; then
  restore_key "node_key.json"
  restore_key "priv_validator_key.json"
fi

# Backup keys
if [ -n "$KEY_PATH" ]; then
  backup_key "node_key.json"
  backup_key "priv_validator_key.json"
fi

# Addressbook
if [ -n "$ADDRBOOK_URL" ]; then
  echo "Downloading addrbook from $ADDRBOOK_URL..."
  curl -sfL $ADDRBOOK_URL > $CONFIG_PATH/addrbook.json
fi

# Download genesis
if [ "$DOWNLOAD_GENESIS" == "1" ]; then
  GENESIS_FILENAME="${GENESIS_FILENAME:-genesis.json}"

  echo "Downloading genesis $GENESIS_URL"
  curl -sfL $GENESIS_URL > genesis.json
  file genesis.json | grep -q 'gzip compressed data' && mv genesis.json genesis.json.gz && gzip -d genesis.json.gz
  file genesis.json | grep -q 'tar archive' && mv genesis.json genesis.json.tar && tar -xf genesis.json.tar && rm genesis.json.tar
  file genesis.json | grep -q 'Zip archive data' && mv genesis.json genesis.json.zip && unzip -o genesis.json.zip

  mkdir -p $CONFIG_PATH
  mv $GENESIS_FILENAME $CONFIG_PATH/genesis.json
fi

# Snapshot
if [ "$DOWNLOAD_SNAPSHOT" == "1" ]; then

  if [ -z "${SNAPSHOT_URL}" ] && [ -n "${SNAPSHOT_BASE_URL}" ]; then
    SNAPSHOT_PATTERN="${SNAPSHOT_PATTERN:-$CHAIN_ID.*$SNAPSHOT_FORMAT}"
    SNAPSHOT_URL=$SNAPSHOT_BASE_URL/$(curl -Ls $SNAPSHOT_BASE_URL/ | egrep -o ">$SNAPSHOT_PATTERN" | tr -d ">");
  fi

  if [ -z "${SNAPSHOT_URL}" ] && [ -n "${SNAPSHOT_JSON}" ]; then
    SNAPSHOT_URL="$(curl -Ls $SNAPSHOT_JSON | jq -r .latest)"
  fi

  if [ -z "${SNAPSHOT_URL}" ] && [ -n "${SNAPSHOT_QUICKSYNC}" ]; then
    SNAPSHOT_PRUNING="${SNAPSHOT_PRUNING:-pruned}"
    SNAPSHOT_DATA_PATH="data"
    SNAPSHOT_URL=`curl -Ls $SNAPSHOT_QUICKSYNC | jq -r --arg FILE "$CHAIN_ID-$SNAPSHOT_PRUNING"  'first(.[] | select(.file==$FILE)) | .url'`
  fi

  # SNAPSHOT_FORMAT default value generation via SNAPSHOT_URL
  if [ -z "${SNAPSHOT_FORMAT}" ]; then
    # DCS Storj backups adding ?download=1 part which needs to be stripped before determining the extension
    SNAPSHOT_URL_TRIM="${SNAPSHOT_URL%?download=1}"
    case "${SNAPSHOT_URL_TRIM,,}" in
      *.tar.gz)   SNAPSHOT_FORMAT="tar.gz";;
      *.tar.lz4)  SNAPSHOT_FORMAT="tar.lz4";;
      *.tar.zst)  SNAPSHOT_FORMAT="tar.zst";;
      # Catchall
      *)          SNAPSHOT_FORMAT="tar";;
    esac
  fi

  if [ -n "${SNAPSHOT_URL}" ]; then
    echo "Downloading snapshot from $SNAPSHOT_URL..."
    rm -rf $PROJECT_ROOT/snapshot;
    mkdir -p $PROJECT_ROOT/snapshot;
    cd $PROJECT_ROOT/snapshot;

    tar_cmd="tar xf -"
    # case insensitive match
    if [[ "${SNAPSHOT_FORMAT,,}" == "tar.gz" ]]; then tar_cmd="tar xzf -"; fi
    if [[ "${SNAPSHOT_FORMAT,,}" == "tar.lz4" ]]; then tar_cmd="lz4 -d | tar xf -"; fi
    if [[ "${SNAPSHOT_FORMAT,,}" == "tar.zst" ]]; then tar_cmd="zstd -cd | tar xf -"; fi

    # Detect content size via HTTP header `Content-Length`
    # Note that the server can refuse to return `Content-Length`, or the URL can be incorrect
    pv_extra_args=""
    snapshot_size_in_bytes=$(wget $SNAPSHOT_URL --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}')
    case "$snapshot_size_in_bytes" in
      # Value cannot be started with `0`, and must be integer
      [1-9]*[0-9]) pv_extra_args="-s $snapshot_size_in_bytes";;
    esac

    # use DCS Storj uplink for the Storj backups (much faster)
    if [[ "${SNAPSHOT_URL}" == *"link.storjshare.io"* ]] && [ -n "$STORJ_ACCESS_GRANT" ]; then
      STORJ_SNAPSHOT_URL=${SNAPSHOT_URL#*link.storjshare.io/s/}
      STORJ_SNAPSHOT_URL=${STORJ_SNAPSHOT_URL#*/}
      STORJ_SNAPSHOT_URL=${STORJ_SNAPSHOT_URL%%\?*}
      (uplink cp $storj_args sj://${STORJ_SNAPSHOT_URL} - | pv -petrafb -i 5 $pv_extra_args | eval $tar_cmd) 2>&1 | stdbuf -o0 tr '\r' '\n' || exit 1
    else
      (wget -nv -O - $SNAPSHOT_URL | pv -petrafb -i 5 $pv_extra_args | eval $tar_cmd) 2>&1 | stdbuf -o0 tr '\r' '\n' || exit 1
    fi

    # if [ -z "$( ls -A ./ )" ]; then
    #   echo "Snapshot download empty, exiting..."
    #   exit 1
    # fi

    [ -z "${SNAPSHOT_DATA_PATH}" ] && [ -d "./${DATA_DIR}" ] && SNAPSHOT_DATA_PATH="${DATA_DIR}"
    [ -z "${SNAPSHOT_WASM_PATH}" ] && [ -d "./${WASM_DIR}" ] && SNAPSHOT_WASM_PATH="${WASM_DIR}"

    if [ -n "${SNAPSHOT_DATA_PATH}" ]; then
      rm -rf ../$DATA_DIR
      mv ./${SNAPSHOT_DATA_PATH} ../$DATA_DIR
    fi

    if [ -n "${SNAPSHOT_WASM_PATH}" ]; then
      rm -rf ../$WASM_DIR
      mv ./${SNAPSHOT_WASM_PATH} ../$WASM_DIR
    fi

    if [ -z "${SNAPSHOT_DATA_PATH}" ]; then
      rm -rf ../$DATA_DIR && mkdir -p ../$DATA_DIR
      mv ./* ../$DATA_DIR
    fi

    cd ../ && rm -rf ./snapshot
  else
    echo "Snapshot URL not found"
  fi
fi

# Validate genesis
[ "$VALIDATE_GENESIS" == "1" ] && $PROJECT_BIN validate-genesis

# Cosmovisor
if [ "$COSMOVISOR_ENABLED" == "1" ]; then
  export COSMOVISOR_VERSION="${COSMOVISOR_VERSION:-"1.6.0"}"
  export COSMOVISOR_URL="${COSMOVISOR_URL:-"https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor%2Fv$COSMOVISOR_VERSION/cosmovisor-v$COSMOVISOR_VERSION-$(uname -s)-$(uname -m | sed "s|x86_64|amd64|").tar.gz"}"

  # Download Binary
  if [ ! -f "/bin/cosmovisor" ]; then
    echo "Downloading Cosmovisor from $COSMOVISOR_URL..."
    mkdir -p cosmovisor_temp
    cd cosmovisor_temp
    curl -Ls $COSMOVISOR_URL | tar zx
    cp cosmovisor /bin/cosmovisor
    cd ..
    rm -r cosmovisor_temp
  fi

  # Set up the environment variables
  export DAEMON_NAME=$PROJECT_BIN
  export DAEMON_HOME=$PROJECT_ROOT
  export DAEMON_SHUTDOWN_GRACE="${DAEMON_SHUTDOWN_GRACE:-15s}"

  # Setup Folder Structure
  mkdir -p $PROJECT_ROOT/cosmovisor/upgrades
  mkdir -p $PROJECT_ROOT/cosmovisor/genesis/bin
  cp "/bin/$PROJECT_BIN" $PROJECT_ROOT/cosmovisor/genesis/bin/
fi

# preseed priv_validator_state.json if missing
# ref. https://github.com/tendermint/tendermint/issues/8389
if [[ ! -f "$PROJECT_ROOT/data/priv_validator_state.json" ]]; then
  mkdir -p "$PROJECT_ROOT/data" 2>/dev/null || :
  echo '{"height":"0","round":0,"step":0}' > "$PROJECT_ROOT/data/priv_validator_state.json"
fi

if [ "$#" -ne 0 ]; then
  export START_CMD="$@"
fi

if [ -z "$START_CMD" ]; then
  if [ "$COSMOVISOR_ENABLED" == "1" ]; then
    export START_CMD="cosmovisor run start"
  else
    export START_CMD="$PROJECT_BIN start"
  fi
fi

if [ -n "$SNAPSHOT_PATH" ]; then
  echo "Running '$START_CMD' with snapshot..."
  exec snapshot.sh "$START_CMD"
else
  echo "Running '$START_CMD'..."
  exec $START_CMD
fi
