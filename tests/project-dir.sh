#!/bin/bash

# Run in a disposable Linux container: the entrypoint uses /root as its base.
# docker run --rm --network none -v "$PWD:/src:ro" -w /src gcc:13 bash tests/project-dir.sh
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d /root/omnibus-paths.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
cd "$test_dir"

export TEST_FIXTURE="$test_dir/fixture"
export TEST_BACKUP="$test_dir/backup.tar"
mkdir -p "$TEST_FIXTURE/data" "$TEST_FIXTURE/wasm"
printf 'block data\n' > "$TEST_FIXTURE/data/block"
printf 'wasm data\n' > "$TEST_FIXTURE/wasm/module"
tar cf "$TEST_FIXTURE/snapshot.tar" -C "$TEST_FIXTURE" data wasm

# Keep the real filesystem and tar operations; replace network/progress tools.
wget() {
  if [[ " $* " != *' --spider '* ]]; then
    cat "$TEST_FIXTURE/snapshot.tar"
  fi
}
pv() { cat; }
s3cmd() { cat > "$TEST_BACKUP"; }
# Stop the snapshot loop after its first backup and clean up its child process.
sleep() {
  kill "$PID"
  wait "$PID" || true
  exit 0
}
export -f wget pv s3cmd sleep

for project_dir in project 'project dir' $'project\tdir' 'project[1]'; do
  project_root="$test_dir/$project_dir"
  printf 'Testing PROJECT_DIR=%q\n' "$project_dir"

  # A matching sibling catches accidental glob expansion as well as splitting.
  mkdir -p "$test_dir/project1/snapshot"
  printf 'keep\n' > "$test_dir/project1/snapshot/sentinel"

  env CHAIN_JSON=0 CHAIN_ID=test PROJECT_BIN=true \
    PROJECT_DIR="${project_root#/root/}" INIT_CONFIG=0 DOWNLOAD_GENESIS=0 \
    SNAPSHOT_RETAIN=0 SNAPSHOT_URL=fixture SNAPSHOT_FORMAT=tar START_CMD=true \
    bash "$repo_dir/entrypoint.sh"

  cmp "$TEST_FIXTURE/data/block" "$project_root/data/block"
  cmp "$TEST_FIXTURE/wasm/module" "$project_root/wasm/module"
  test -f "$project_root/data/priv_validator_state.json"
  test ! -e "$project_root/snapshot"
  test -f "$test_dir/project1/snapshot/sentinel"

  env PROJECT_ROOT="$project_root" SNAPSHOT_ON_START=1 SNAPSHOT_RETAIN=0 \
    SNAPSHOT_METADATA=0 SNAPSHOT_PATH=test-bucket SNAPSHOT_SAVE_FORMAT=tar \
    SNAPSHOT_CMD='/bin/sleep 30' \
    bash "$repo_dir/snapshot.sh"

  tar xOf "$TEST_BACKUP" ./block | cmp "$TEST_FIXTURE/data/block" -
  printf 'PASS: snapshot restored and backed up\n'
done
