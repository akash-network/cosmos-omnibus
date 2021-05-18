#!/bin/bash

genmoniker(){
  echo "cosmos-omnibus-$(dd if=/dev/random bs=1 count=3 status=none | od -An -x | tr -d ' ')"
}

export NODE_HOME="${NODE_HOME:-/home}"
export NODE_MONIKER="${NODE_MONIKER:-cosmos-omnibus-$(genmoniker)}"

URL_BASE="${URL_BASE:-https://raw.githubusercontent.com/ovrclk/cosmos-omnibus/master/data}"
NETWORK_VARIANT="${NETWORK_VARIANT:-mainnet}"
METADATA_URL_BASE="${METADATA_URL_BASE:-"$URL_BASE/$COSMOS_OMNIBUS_PROJECT/$NETWORK_VARIANT"}"

export NODE_CHAIN_ID="${NODE_CHAIN_ID:-$(curl -sL "$METADATA_URL_BASE/chain-id.txt")}"
export NODE_GENESIS_URL="${NODE_GENESIS_URL:-"$METADATA_URL_BASE/genesis.json"}"
export NODE_SEEDS="${NODE_SEEDS:-$(curl -sL "$METADATA_URL_BASE/seed-nodes.txt" | paste -sd ',')}"
export NODE_PEERS="${NODE_PEERS:-$(curl -sL "$METADATA_URL_BASE/peer-nodes.txt" | paste -sd ',')}"
export PRIVATE_PEER_IDS="${PRIVATE_PEER_IDS:-""}"
export RPC_LIST="${RPC_LIST:-"$METADATA_URL_BASE/rpc-nodes.txt"}"

/bin/node init "$NODE_MONIKER" --home $NODE_HOME
curl -s "$NODE_GENESIS_URL" > $NODE_HOME/config/genesis.json
sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' $NODE_HOME/config/config.toml
sed -i '/persistent_peers =/c\persistent_peers = "'"$NODE_PEERS"'"' $NODE_HOME/config/config.toml
sed -i '/seeds =/c\seeds = "'"$NODE_SEEDS"'"' $NODE_HOME/config/config.toml
/bin/node validate-genesis --home $NODE_HOME

do_init(){
  # enable api in app.toml
  cat $NODE_HOME/config/app.toml | python3 -u /patch_node_config.py enable_api > patched_app.toml
  if [ $? -eq 0 ]; then
    mv patched_app.toml $NODE_HOME/config/app.toml
  fi
  /bin/node start --home $NODE_HOME
}

do_init_snapshot(){
  rm -rf "$NODE_HOME"/data
  mkdir -p "$NODE_HOME"/data
  cd "$NODE_HOME"/data
  if [[ -z "${SNAPSHOT_URL}" ]]; then
    SNAPSHOT_URL=http://135.181.60.250/akash/$(curl -s http://135.181.60.250/akash/ | egrep -o ">akashnet-2.*tar" | tr -d ">");
  fi
  echo "Downloading snapshot from $SNAPSHOT_URL..."
  wget -nv -O - $SNAPSHOT_URL | tar xf -
  do_init
}

do_init_statesync(){ 
  cat $NODE_HOME/config/config.toml | python3 -u /patch_node_config.py state_sync > patched_config.toml
  if [ $? -eq 0 ]; then
    mv patched_config.toml $NODE_HOME/config/config.toml
  fi
  do_init
}

do_setup_sentry(){
  sed -i "/pex =/c\pex = true" $NODE_HOME//config/config.toml
  sed -i "/addr_book_strict =/c\addr_book_strict = true" $NODE_HOME/config/config.toml
  sed -i '/private_peer_ids =/c\private_peer_ids = "'"$PRIVATE_PEER_IDS"'"' $NODE_HOME/config/config.toml
}

# pass second argument as sentry for sentry-node
case "$2" in
  sentry)
    do_setup_sentry
    ;;
esac

case "$1" in
  init)
    do_init
    ;;
  init-snapshot)
    do_init_snapshot
    ;;
  init-statesync)
    do_init_statesync
    ;;
  *)
    exec /bin/node "$@"
esac


