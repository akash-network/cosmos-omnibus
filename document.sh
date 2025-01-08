#!/bin/bash

set -e

OMNIBUS_IMAGE="cosmos-omnibus:v1.1.1"

if [ "$#" -gt 0 ]; then
  DIRS="$@"
else
  DIRS=$(find . -type f -name "build.yml" -exec dirname {} \; | sort -u)
fi

for dir in $DIRS; do
  PROJECT=$(basename $dir)
  [ "$PROJECT" == "generic" ] && continue

  echo "Processing directory: $PROJECT"

  PROJECT_BIN=$(yq '.services.node.build.args.PROJECT_BIN // ""' $dir/build.yml)
  PROJECT_BIN="${PROJECT_BIN:-$PROJECT}"
  PROJECT_DIR=$(yq '.services.node.build.args.PROJECT_DIR // ""' $dir/build.yml)
  PROJECT_DIR="${PROJECT_DIR:-.$PROJECT_BIN}"
  NAMESPACE=$(yq '.services.node.build.args.NAMESPACE // ""' $dir/build.yml)
  NAMESPACE="${NAMESPACE:-$(echo ${PROJECT_BIN} | tr '[:lower:]' '[:upper:]' | tr '-' '_')}"
  VERSION=$(yq '.services.node.build.args.VERSION' $dir/build.yml)
  REPOSITORY=$(yq '.services.node.build.args.REPOSITORY' $dir/build.yml)
  IMAGE="ghcr.io/akash-network/${OMNIBUS_IMAGE}-${PROJECT}-${VERSION}"

  CHAIN_JSON="https://raw.githubusercontent.com/cosmos/chain-registry/master/${PROJECT}/chain.json"
  CHAIN_JSON_EXISTS=false
  if curl --output /dev/null --silent --head --fail "$CHAIN_JSON"; then
    CHAIN_JSON_EXISTS=true
  else
    echo "${PROJECT}: Chain JSON not found"
  fi

  if [[ $CHAIN_JSON_EXISTS == true ]]; then
    sleep 0.5 # avoid rate limiting
    CHAIN_METADATA=$(curl -Ls $CHAIN_JSON)
    PROJECT_NAME="$(echo $CHAIN_METADATA | jq -r .pretty_name)"
    PROJECT_STATUS="$(echo $CHAIN_METADATA | jq -r .status)"
    if [ $PROJECT_STATUS != "live" ]; then
      echo "${PROJECT}: Chain is not live (${PROJECT_STATUS})"
    fi
  else
    PROJECT_NAME=$PROJECT
  fi

  POLKACHU_CHAIN_ID=$(yq '.services.node.build.args.POLKACHU_CHAIN_ID // ""' $dir/build.yml)
  POLKACHU_CHAIN_ID="${POLKACHU_CHAIN_ID:-$PROJECT}"
  POLKACHU_CHAIN=`curl -Ls https://polkachu.com/api/v2/chains/$POLKACHU_CHAIN_ID | jq .`
  POLKACHU_SUCCESS=$(echo $POLKACHU_CHAIN | jq -r '.success')
  if [ $POLKACHU_SUCCESS = false ]; then
    echo "${PROJECT}: Polkachu chain not found"
    POLKACHU_SUPPORT=false
  else
    POLKACHU_SUPPORT=true
    POLKACHU_SEEDS_SUPPORT=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.seed.active')
    POLKACHU_PEERS_SUPPORT=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.live_peers.active')
    POLKACHU_STATESYNC_SUPPORT=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.state_sync.active')
    POLKACHU_ADDRBOOK_SUPPORT=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.addrbook.active')
    POLKACHU_SNAPSHOT_SUPPORT=$(echo $POLKACHU_CHAIN | jq -r '.polkachu_services.snapshot.active')
  fi

  yq ./_templates/docker-compose.yml > $dir/docker-compose.yml
  yq -i ".services.node.image = \"${IMAGE}\"" $dir/docker-compose.yml
  yq -i ".services.node.volumes = [\"./node-data:/root/${PROJECT_DIR}\"]" $dir/docker-compose.yml
  yq -i ".services.node.environment += load(\"${dir}/build.yml\").services.node.environment" $dir/docker-compose.yml

  yq ./_templates/deploy.yml > $dir/deploy.yml
  yq -i ".services.node.image = \"${IMAGE}\"" $dir/deploy.yml
  yq -i ".services.node.params.storage.data.mount = \"/root/${PROJECT_DIR}\"" $dir/deploy.yml
  yq -i ".services.node.env += load(\"${dir}/build.yml\").services.node.environment" $dir/deploy.yml

  if [ $POLKACHU_SUPPORT = true ]; then
    yq -i ".services.node.environment += [\"P2P_POLKACHU=1\", \"STATESYNC_POLKACHU=1\", \"ADDRBOOK_POLKACHU=1\"]" $dir/docker-compose.yml
    yq -i ".services.node.env += [\"P2P_POLKACHU=1\", \"STATESYNC_POLKACHU=1\", \"ADDRBOOK_POLKACHU=1\"]" $dir/deploy.yml
  fi

  cat << EOF > $dir/README.md
# $PROJECT_NAME

| | |
|---|---|
|Version|\`$VERSION\`|
|Binary|\`$PROJECT_BIN\`|
|Directory|\`$PROJECT_DIR\`|
|ENV namespace|\`$NAMESPACE\`|
|Repository|\`$REPOSITORY\`|
|Image|\`$IMAGE\`|

## Examples

- Run on Akash with the [example deploy.yml](./deploy.yml)
- Run with Docker using the [example docker-compose.yml](./docker-compose.yml)
EOF

  if [ $CHAIN_JSON_EXISTS = true ]; then
    cat << EOF >> $dir/README.md

## Chain information

The [Cosmos Chain Registry](https://github.com/cosmos/chain-registry) publishes [up to date chain info]($CHAIN_JSON) for $PROJECT_NAME.

This will be used automatically unless overridden with the \`CHAIN_JSON\` variable (use \`0\` to disable).
EOF
  fi

  if $(yq '.services.node.environment // [] | any' $dir/build.yml); then
    cat << EOF >> $dir/README.md

## Suggested configuration

The following configuration is recommended for $PROJECT_NAME nodes.

|Variable|Value|
|---|---|
EOF
    ENV_VARS=$(yq '.services.node.environment[]' $dir/build.yml)
    for env_var in $ENV_VARS; do
      key=$(echo $env_var | cut -d '=' -f 1)
      value=$(echo $env_var | cut -d '=' -f 2-)
      cat << EOF >> $dir/README.md
|\`${key}\`|\`${value}\`|
EOF
    done
  fi

  if [ $POLKACHU_SUPPORT = true ]; then
    cat << EOF >> $dir/README.md

## Polkachu Chain Services

[Polkachu's Chain Services](https://www.polkachu.com/) make bootstrapping a node extremely easy. They provide live peers, seeds, statesync, addrbooks and pruned snapshots among other features.

The following configuration is available for $PROJECT_NAME nodes. [See the documentation](../README.md#polkachu-services) for more information.

|Variable|Value|
|---|---|
EOF

    if [ $POLKACHU_SEEDS_SUPPORT = true ] || [ $POLKACHU_PEERS_SUPPORT = true ]; then
      cat << EOF >> $dir/README.md
|\`P2P_POLKACHU\`|\`1\`|
EOF
    fi
    if [ $POLKACHU_SEEDS_SUPPORT = true ]; then
      cat << EOF >> $dir/README.md
|\`P2P_SEEDS_POLKACHU\`|\`1\`|
EOF
    fi
    if [ $POLKACHU_PEERS_SUPPORT = true ]; then
      cat << EOF >> $dir/README.md
|\`P2P_PEERS_POLKACHU\`|\`1\`|
EOF
    fi
    if [ $POLKACHU_STATESYNC_SUPPORT = true ]; then
      cat << EOF >> $dir/README.md
|\`STATESYNC_POLKACHU\`|\`1\`|
EOF
    fi
    if [ $POLKACHU_ADDRBOOK_SUPPORT = true ]; then
      cat << EOF >> $dir/README.md
|\`ADDRBOOK_POLKACHU\`|\`1\`|
EOF
    fi

    if [ $POLKACHU_SNAPSHOT_SUPPORT = true ]; then
      cat << EOF >> $dir/README.md

Polkachu also provide pruned snapshots for $PROJECT_NAME. Find the [latest snapshot](https://polkachu.com/tendermint_snapshots/akash) and apply it using the \`SNAPSHOT_URL\` variable.
EOF
    fi
  fi
done
