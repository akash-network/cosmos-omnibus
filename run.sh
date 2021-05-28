#!/bin/bash

set -e

export PROJECT_HOME="/root/$PROJECT_DIR"
export CHAIN_ID="${CHAIN_ID:-$(curl -sfL "$METADATA_URL/chain-id.txt")}"
export SEED_NODES="${SEED_NODES:-$(curl -sfL "$METADATA_URL/seed-nodes.txt" | paste -sd ',')}"
export GENESIS_URL="${GENESIS_URL:-$METADATA_URL/genesis.json}"
export NAMESPACE="${NAMESPACE:-$(echo ${PROJECT^^})}"

[ -z "$CHAIN_ID" ] && echo "CHAIN_ID not found" && exit
[ -z "$SEED_NODES" ] && echo "SEED_NODES not found" && exit

export "${NAMESPACE}_P2P_SEEDS=$SEED_NODES"
export "${NAMESPACE}_P2P_PERSISTENT_PEERS"=$SEED_NODES

export "${NAMESPACE}_RPC_LADDR"="${RPC_LADDR:-tcp://0.0.0.0:26657}"
export "${NAMESPACE}_FASTSYNC_VERSION"="${FASTSYNC_VERSION:v2}"
export "${NAMESPACE}_MINIMUM_GAS_PRICES"="${MINIMUM_GAS_PRICES:0.025$DENOM}"

GENESIS_FILE=$PROJECT_HOME/config/genesis.json
if [ ! -f "$GENESIS_FILE" ]; then
  $PROJECT_BIN init "$MONIKER" --chain-id "$CHAIN_ID"

  curl -sfL $GENESIS_URL > genesis.json
  file genesis.json | grep -q 'gzip compressed data' && mv genesis.json genesis.json.gz && gzip -d genesis.json.gz
  mv genesis.json $GENESIS_FILE
fi

$PROJECT_BIN validate-genesis

# Statesync
# Snapshot

exec "$@"
