#!/bin/bash

set -e

COMMAND="${COMMAND:-$PROJECT_CMD}"
RUN_AT="${RUN_AT:-20:33:00}"
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_HOME/data}"
BACKUP_PATH="${BACKUP_PATH}"
BACKUP_RETAIN="${BACKUP_RETAIN:-2 days}"
DATE=`date -u +%T`

echo "$DATE: Starting server"
echo "$DATE: Backup will run at $RUN_AT"
$COMMAND &
PID=$!

while true; do
    DATE=`date -u +%T`
    if [[ $DATE == $RUN_AT ]]; then
        echo "$DATE: Stopping server"
        kill -15 $PID
        wait

        echo "$DATE: Running backup"
        aws_args="--endpoint-url https://s3.filebase.com"
        s3_uri_base="s3://${BACKUP_PATH}"
        timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
        s3_uri="${s3_uri_base}/backup_${timestamp}.tar.gz"

        tar c $BACKUP_DIR | gzip | aws $aws_args s3 cp - "$s3_uri"

        echo "$DATE: Deleting backups older than $BACKUP_RETAIN"
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

        echo "$DATE: Restarting server"
        $COMMAND &
        PID=$!
        sleep 1s
    fi
done
