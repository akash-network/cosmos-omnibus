#!/bin/bash

genmoniker(){
  echo "cosmos-omnibus-$(dd if=/dev/random bs=1 count=3 status=none | od -An -x | tr -d ' ')"
}

export NODE_HOME="${AKASH_HOME:-/home}"
export NODE_MONIKER="${NODE_MONIKER:-cosmos-omnibus-$(genmoniker)}"

URL_BASE="${URL_BASE:-https://raw.githubusercontent.com/ovrclk/cosmos-omnibus/master/data}"
NETWORK_VARIANT="${NETWORK_VARIANT:-mainnet}"
METADATA_URL_BASE="${METADATA_URL_BASE:-"$URL_BASE/$COSMOS_OMNIBUS_PROJECT/$NETWORK_VARIANT"}"

export NODE_CHAIN_ID="${NODE_CHAIN_ID:-$(curl -sL "$METADATA_URL_BASE/chain-id.txt")}"
export NODE_SEEDS="${NODE_SEEDS:-$(curl -sL "$METADATA_URL_BASE/seed-nodes.txt" | paste -sd ',')}"

/bin/node init "$NODE_MONIKER"
curl -s "$METADATA_URL_BASE/genesis.json" > $NODE_HOME/config/genesis.json
akash validate-genesis

do_init(){
}

do_init_snapshot(){
# rm -rf "$NODE_HOME"/data
# mkdir -p "$NODE_HOME"/data
# ( 
#   cd "$NODE_HOME" && \
#   if [[ -z "${SNAPSHOT_URL}" ]]; then
#     SNAPSHOT_URL=http://135.181.60.250/akash/$(curl -s http://135.181.60.250/akash/ | egrep -o ">akashnet-2.*tar" | tr -d ">");
#   fi
#   echo "Downloading snapshot from $SNAPSHOT_URL..."
#   wget -nv -O - $SNAPSHOT_URL | tar xf -
# )
}

do_init_statesync(){
}


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


