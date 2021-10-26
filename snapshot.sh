#!/bin/bash

set -e

SNAPSHOT_TIME="${SNAPSHOT_TIME:-00:00:00}"
SNAPSHOT_DAY="${SNAPSHOT_DAY:-*}"
SNAPSHOT_SIZE="${SNAPSHOT_SIZE:-107374182400}"
SNAPSHOT_DIR="${SNAPSHOT_DIR:-$PROJECT_HOME/data}"
SNAPSHOT_CMD="${SNAPSHOT_CMD:-$@}"
SNAPSHOT_PATH="${SNAPSHOT_PATH}"
SNAPSHOT_RETAIN="${SNAPSHOT_RETAIN:-2 days}"
SNAPSHOT_METADATA="${SNAPSHOT_METADATA:-1}"
TIME=$(date -u +%T)
DOW=$(date +%u)

echo "$TIME: Starting server"
echo "$TIME: Snapshot will run at $SNAPSHOT_TIME on day $SNAPSHOT_DAY"
$SNAPSHOT_CMD &
PID=$!

while true; do
    TIME=$(date -u +%T)
    DOW=$(date +%u)
    if [[ ($SNAPSHOT_DAY == "*") || ($SNAPSHOT_DAY == $DOW) ]] && [[ $SNAPSHOT_TIME == $TIME ]]; then
        echo "$TIME: Stopping server"
        kill -15 $PID
        wait

        echo "$TIME: Running snapshot"
        aws_args="--endpoint-url ${S3_HOST}"
        s3_uri_base="s3://${SNAPSHOT_PATH}"
        timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
        s3_uri="${s3_uri_base}/snapshot_${timestamp}.tar.gz"

        tar c -C $SNAPSHOT_DIR . | gzip | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE

        if [[ $SNAPSHOT_RETAIN != "0" || $SNAPSHOT_METADATA != "0" ]]; then
            readarray -t s3Files < <(aws $aws_args s3 ls "${s3_uri_base}/snapshot_")
            snapshots=()
            for line in "${s3Files[@]}"; do
                createDate=`echo $line|awk {'print $1" "$2'}`
                createDate=`date -d"$createDate" +%s`
                fileName=`echo $line|awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//'`
                if [ "$SNAPSHOT_RETAIN" != "0" ]; then
                    olderThan=`date -d"-$SNAPSHOT_RETAIN" +%s`
                    if [[ $createDate -lt $olderThan ]]; then
                        if [[ $fileName != "" ]]; then
                            echo "$TIME: Deleting snapshot $fileName"
                            aws $aws_args s3 rm "${s3_uri_base}/$fileName"
                        fi
                    else
                        snapshots+=("$fileName")
                    fi
                else
                    snapshots+=("$fileName")
                fi
            done;

            if [ "$SNAPSHOT_METADATA" != "0" ]; then
                echo "$TIME: Uploading metadata"
                snapshotJson="[]"
                for val in ${snapshots[@]}; do
                    snapshotJson="$(echo $snapshotJson | jq ".+[\"$val\"]")"
                done
                echo $snapshotJson | jq '{chain_id: $c, snapshots: ., latest: $l}' \
                   --arg c "$CHAIN_ID" --arg l "${snapshots[-1]}" | \
                   aws $aws_args s3 cp - "${s3_uri_base}/snapshot.json"
            fi
        fi

        echo "$TIME: Restarting server"
        $SNAPSHOT_CMD &
        PID=$!
        sleep 1s
    else
        if ! kill -0 $PID; then
            echo "$TIME: Process has died. Exiting"
            break;
        fi
    fi
done
