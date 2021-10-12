#!/bin/bash

set -e

COMMAND="${COMMAND:-$PROJECT_CMD}"
RUN_AT="${RUN_AT:-00:00:00}"
RUN_ON="${RUN_ON:-*}"
EXPECTED_SIZE="${EXPECTED_SIZE}"
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_HOME/data}"
BACKUP_PATH="${BACKUP_PATH}"
BACKUP_RETAIN="${BACKUP_RETAIN:-2 days}"
TIME=$(date -u +%T)
DOW=$(date +%u)

echo "$TIME: Starting server"
echo "$TIME: Backup will run at $RUN_AT on day $RUN_ON"
$COMMAND &
PID=$!

while true; do
    TIME=$(date -u +%T)
    DOW=$(date +%u)
    if [[ ($RUN_ON == "*") || ($RUN_ON == $DOW) ]] && [[ $TIME == $RUN_AT ]]; then
        echo "$TIME: Stopping server"
        kill -15 $PID
        wait

        echo "$TIME: Running backup"
        aws_args="--endpoint-url https://s3.filebase.com"
        s3_uri_base="s3://${BACKUP_PATH}"
        timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
        s3_uri="${s3_uri_base}/backup_${timestamp}.tar.gz"

        tar c $BACKUP_DIR | gzip | aws $aws_args s3 cp - "$s3_uri" --expected-size $EXPECTED_SIZE

        echo "$TIME: Deleting backups older than $BACKUP_RETAIN"
        aws $aws_args s3 ls "${s3_uri_base}/backup_" | while read -r line; do
            createDate=`echo $line|awk {'print $1" "$2'}`
            createDate=`date -d"$createDate" +%s`
            olderThan=`date -d"-$BACKUP_RETAIN" +%s`
            if [[ $createDate -lt $olderThan ]]; then
                fileName=`echo $line|awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//'`
                if [[ $fileName != "" ]]; then
                    aws $aws_args s3 rm "${s3_uri_base}/$fileName"
                fi
            fi
        done;

        echo "$TIME: Restarting server"
        $COMMAND &
        PID=$!
        sleep 1s
    else
        if ! kill -0 $PID; then
            echo "$TIME: Process has died. Exiting"
            break;
        fi
    fi
done
