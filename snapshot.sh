#!/bin/bash

set -e

SNAPSHOT_TIME="${SNAPSHOT_TIME:-00:00:00}"
SNAPSHOT_DAY="${SNAPSHOT_DAY:-*}"
SNAPSHOT_SIZE="${SNAPSHOT_SIZE:-107374182400}"
SNAPSHOT_DIR="${SNAPSHOT_DIR:-$PROJECT_HOME/data}"
SNAPSHOT_CMD="${SNAPSHOT_CMD:-$@}"
SNAPSHOT_PATH="${SNAPSHOT_PATH}"
SNAPSHOT_RETAIN="${SNAPSHOT_RETAIN:-2 days}"
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
        aws_args="--endpoint-url https://s3.filebase.com"
        s3_uri_base="s3://${SNAPSHOT_PATH}"
        timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
        s3_uri="${s3_uri_base}/snapshot_${timestamp}.tar.gz"

        tar c -C $SNAPSHOT_DIR . | gzip | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE

        echo "$TIME: Deleting snapshots older than $SNAPSHOT_RETAIN"
        aws $aws_args s3 ls "${s3_uri_base}/snapshot_" | while read -r line; do
            createDate=`echo $line|awk {'print $1" "$2'}`
            createDate=`date -d"$createDate" +%s`
            olderThan=`date -d"-$SNAPSHOT_RETAIN" +%s`
            if [[ $createDate -lt $olderThan ]]; then
                fileName=`echo $line|awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//'`
                if [[ $fileName != "" ]]; then
                    aws $aws_args s3 rm "${s3_uri_base}/$fileName"
                fi
            fi
        done;

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
