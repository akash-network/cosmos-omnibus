#!/bin/bash

set -e

export PROJECT_HOME="/root/$PROJECT_DIR"
export CHAIN_ID="${CHAIN_ID:-$(curl -sfL "$METADATA_URL/chain-id.txt")}"
export SEED_NODES="${SEED_NODES:-$(curl -sfL "$METADATA_URL/seed-nodes.txt" | paste -sd ',')}"
export GENESIS_URL="${GENESIS_URL:-$METADATA_URL/genesis.json}"
export NAMESPACE="${NAMESPACE:-$(echo ${PROJECT^^})}"
export VALIDATE_GENESIS="${VALIDATE_GENESIS:-1}"

[ -z "$CHAIN_ID" ] && echo "CHAIN_ID not found" && exit

export "${NAMESPACE}_P2P_SEEDS=${P2P_SEEDS:-$SEED_NODES}"
export "${NAMESPACE}_P2P_PERSISTENT_PEERS"=${P2P_PERSISTENT_PEERS:-$SEED_NODES}

export "${NAMESPACE}_RPC_LADDR"="${RPC_LADDR:-tcp://0.0.0.0:26657}"
export "${NAMESPACE}_FASTSYNC_VERSION"="${FASTSYNC_VERSION:-v2}"
[ ! -z "$MINIMUM_GAS_PRICES" ] && export "${NAMESPACE}_MINIMUM_GAS_PRICES"=$MINIMUM_GAS_PRICES

GENESIS_FILE=$PROJECT_HOME/config/genesis.json
if [ ! -f "$GENESIS_FILE" ]; then
  $PROJECT_BIN init "$MONIKER" --chain-id "$CHAIN_ID"

  curl -sfL $GENESIS_URL > genesis.json
  file genesis.json | grep -q 'gzip compressed data' && mv genesis.json genesis.json.gz && gzip -d genesis.json.gz
  file genesis.json | grep -q 'Zip archive data' && mv genesis.json genesis.json.zip && unzip -o genesis.json.zip
  mv genesis.json $GENESIS_FILE
fi

if [ ! -z "$TRUSTED_NODE" ]; then
  LATEST_HEIGHT=$(curl -s $TRUSTED_NODE/block | jq -r .result.block.header.height)
  BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
  TRUST_HASH=$(curl -s "$TRUSTED_NODE/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
  export "${NAMESPACE}_STATESYNC_TRUST_HEIGHT=$BLOCK_HEIGHT"
  export "${NAMESPACE}_STATESYNC_TRUST_HASH=$TRUST_HASH"
  export "${NAMESPACE}_STATESYNC_TRUST_PERIOD=168h0m0s"
fi

[ "$VALIDATE_GENESIS" == "1" ] && $PROJECT_BIN validate-genesis

# Statesync
# Snapshot

exec "$@"
