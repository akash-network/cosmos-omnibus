#!/bin/bash

set -e

export PROJECT_HOME="/root/$PROJECT_DIR"
export CHAIN_ID="${CHAIN_ID:-$(curl -sfL "$METADATA_URL/chain-id.txt")}"
export SEED_NODES="${SEED_NODES:-$(curl -sfL "$METADATA_URL/seed-nodes.txt" | paste -sd ',')}"
export GENESIS_URL="${GENESIS_URL:-$METADATA_URL/genesis.json}"
export NAMESPACE="${NAMESPACE:-$(echo ${PROJECT^^})}"
export VALIDATE_GENESIS="${VALIDATE_GENESIS:-1}"
if [[ -z $BOOTSTRAP && ( -n $SNAPSHOT_URL || -n $SNAPSHOT_BASE_URL ) ]]; then
  export BOOTSTRAP="1"
fi

[ -z "$CHAIN_ID" ] && echo "CHAIN_ID not found" && exit

export AWS_ACCESS_KEY_ID=$S3_KEY
export AWS_SECRET_ACCESS_KEY=$S3_SECRET
export S3_HOST="${S3_HOST:-https://s3.filebase.com}"

if [ -n "$KEY_PATH" ]; then
  s3_uri_base="s3://${KEY_PATH}"
  aws_args="--endpoint-url ${S3_HOST}"
  if [ -n "$KEY_PASSWORD" ]; then
    file_suffix=".gpg"
  else
    file_suffix=""
  fi
fi

restore_key () {
  existing=$(aws $aws_args s3 ls "${s3_uri_base}/$1" | head -n 1)
  if [[ -z $existing ]]; then
    echo "$1 backup not found"
  else
    echo "Restoring $1"
    aws $aws_args s3 cp "${s3_uri_base}/$1" $PROJECT_HOME/config/$1$file_suffix

    if [ -n "$KEY_PASSWORD" ]; then
      echo "Decrypting"
      gpg --decrypt --batch --passphrase "$KEY_PASSWORD" $PROJECT_HOME/config/$1$file_suffix > $PROJECT_HOME/config/$1
      rm $PROJECT_HOME/config/$1$file_suffix
    fi
  fi
}

backup_key () {
  existing=$(aws $aws_args s3 ls "${s3_uri_base}/$1" | head -n 1)
  if [[ -z $existing ]]; then
    echo "Backing up $1"
    if [ -n "$KEY_PASSWORD" ]; then
      echo "Encrypting backup..."
      gpg --symmetric --batch --passphrase "$KEY_PASSWORD" $PROJECT_HOME/config/$1
    fi
    aws $aws_args s3 cp $PROJECT_HOME/config/$1$file_suffix "${s3_uri_base}/$1"
    [ -n "$KEY_PASSWORD" ] && rm $PROJECT_HOME/config/$1.gpg
  fi
}

if [ ! -d "$PROJECT_HOME/config" ]; then
  $PROJECT_BIN init "$MONIKER" --chain-id "$CHAIN_ID"

  echo "Downloading genesis"
  curl -sfL $GENESIS_URL > genesis.json
  file genesis.json | grep -q 'gzip compressed data' && mv genesis.json genesis.json.gz && gzip -d genesis.json.gz
  file genesis.json | grep -q 'Zip archive data' && mv genesis.json genesis.json.zip && unzip -o genesis.json.zip
  mv genesis.json $PROJECT_HOME/config/genesis.json
fi

# Validate genesis
[ "$VALIDATE_GENESIS" == "1" ] && $PROJECT_BIN validate-genesis

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

# Snapshot
if [ "$BOOTSTRAP" == "1" ]; then
  SNAPSHOT_FORMAT="${SNAPSHOT_FORMAT:-tar.gz}"
  SNAPSHOT_PATTERN="${SNAPSHOT_PATTERN:-$CHAIN_ID.*$SNAPSHOT_FORMAT}"

  rm -rf $PROJECT_HOME/data;
  mkdir -p $PROJECT_HOME/data;
  cd $PROJECT_HOME/data
  if [ -z "${SNAPSHOT_URL}" ] && [ -n "${SNAPSHOT_BASE_URL}" ]; then
    SNAPSHOT_URL=$SNAPSHOT_BASE_URL/$(curl -s $SNAPSHOT_BASE_URL/ | egrep -o ">$SNAPSHOT_PATTERN" | tr -d ">");
  fi

  echo "Downloading snapshot from $SNAPSHOT_URL..."
  [[ $SNAPSHOT_FORMAT = "tar.gz" ]] && tar_args="xzf" || tar_args="xf"
  wget -nv -O - $SNAPSHOT_URL | tar $tar_args -
fi

# Config
export "${NAMESPACE}_RPC_LADDR"="${RPC_LADDR:-tcp://0.0.0.0:26657}"
export "${NAMESPACE}_FASTSYNC_VERSION"="${FASTSYNC_VERSION:-v2}"
[ -n "$MINIMUM_GAS_PRICES" ] && export "${NAMESPACE}_MINIMUM_GAS_PRICES"=$MINIMUM_GAS_PRICES
[ -n "$PRUNING" ] && export "${NAMESPACE}_PRUNING"=$PRUNING

# Peers
export "${NAMESPACE}_P2P_SEEDS=${P2P_SEEDS:-$SEED_NODES}"
export "${NAMESPACE}_P2P_PERSISTENT_PEERS"=${P2P_PERSISTENT_PEERS:-$SEED_NODES}

# Statesync
if [ -n "$STATESYNC_SNAPSHOT_INTERVAL" ]; then
  export "${NAMESPACE}_STATE_SYNC_SNAPSHOT_INTERVAL=$STATESYNC_SNAPSHOT_INTERVAL"
fi

if [ -n "$STATESYNC_RPC_SERVERS" ]; then
  export "${NAMESPACE}_STATESYNC_ENABLE=${STATESYNC_ENABLE:-true}"
  export "${NAMESPACE}_STATESYNC_RPC_SERVERS=$STATESYNC_RPC_SERVERS"
  TRUSTED_NODE=${TRUSTED_NODE:-$(reset(explode(',', $STATESYNC_RPC_SERVERS)))}
  if [ -n "$TRUSTED_NODE" ]; then
    LATEST_HEIGHT=$(curl -s $TRUSTED_NODE/block | jq -r .result.block.header.height)
    BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
    TRUST_HASH=$(curl -s "$TRUSTED_NODE/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
    export "${NAMESPACE}_STATESYNC_TRUST_HEIGHT=${STATESYNC_TRUST_HEIGHT:-$BLOCK_HEIGHT}"
    export "${NAMESPACE}_STATESYNC_TRUST_HASH=${STATESYNC_TRUST_HASH:-$TRUST_HASH}"
    export "${NAMESPACE}_STATESYNC_TRUST_PERIOD=${STATESYNC_TRUST_PERIOD:-168h0m0s}"
  fi
fi

echo "Node ID:"
$PROJECT_BIN tendermint show-node-id

exec "$@"
