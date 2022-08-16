#!/bin/bash

set -e

SNAPSHOT_TIME="${SNAPSHOT_TIME:-00:00:00}"
SNAPSHOT_DAY="${SNAPSHOT_DAY:-*}"
SNAPSHOT_DIR="${SNAPSHOT_DIR:-$PROJECT_ROOT/data}"
SNAPSHOT_CMD="${SNAPSHOT_CMD:-$@}"
SNAPSHOT_PATH="${SNAPSHOT_PATH}"
SNAPSHOT_PREFIX="${SNAPSHOT_PREFIX:-$CHAIN_ID}"
SNAPSHOT_RETAIN="${SNAPSHOT_RETAIN:-2 days}"
SNAPSHOT_METADATA="${SNAPSHOT_METADATA:-1}"
SNAPSHOT_SAVE_FORMAT="${SNAPSHOT_SAVE_FORMAT:-$SNAPSHOT_FORMAT}"
valid_snapshot_formats=(tar tar.gz tar.zst)
# If not one of valid format values, set it to default value
if ! echo "${valid_snapshot_formats[@]}" | grep -qiw -- "$SNAPSHOT_SAVE_FORMAT"; then
  SNAPSHOT_SAVE_FORMAT=tar.gz
fi

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
        s3_uri="${s3_uri_base}/${SNAPSHOT_PREFIX}_${timestamp}.${SNAPSHOT_SAVE_FORMAT}"

        SNAPSHOT_SIZE=$(du -sb $SNAPSHOT_DIR | cut -f1)

        case "${SNAPSHOT_SAVE_FORMAT,,}" in
          tar.gz)   (tar c -C $SNAPSHOT_DIR . | gzip -1 | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE) 2>&1 | stdbuf -o0 tr '\r' '\n';;
          # Compress level can be set via `ZSTD_CLEVEL`, default `3`
          # No. of threads can be set via `ZSTD_NBTHREADS`, default `1`, `0` = detected no. of cpu cores
          tar.zst)  (tar c -C $SNAPSHOT_DIR . | zstd -c | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE) 2>&1 | stdbuf -o0 tr '\r' '\n';;
          # Catchall, assume to be tar
          *)        (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE) 2>&1 | stdbuf -o0 tr '\r' '\n';;
        esac

        if [[ $SNAPSHOT_RETAIN != "0" || $SNAPSHOT_METADATA != "0" ]]; then
            readarray -t s3Files < <(aws $aws_args s3 ls "${s3_uri_base}/${SNAPSHOT_PREFIX}_")
            snapshots=()
            for line in "${s3Files[@]}"; do
                createDate=`echo $line|awk {'print $1" "$2'}`
                createDate=`date -d"$createDate" +%s`
                fileName=`echo $line|awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//'`
                if [[ -n $SNAPSHOT_METADATA_URL && $SNAPSHOT_METADATA_URL != */ ]]; then
                    fileUrl="${SNAPSHOT_METADATA_URL}/${fileName}"
                else
                    fileUrl="${SNAPSHOT_METADATA_URL}${fileName}"
                fi
                if [ "$SNAPSHOT_RETAIN" != "0" ]; then
                    olderThan=`date -d"-$SNAPSHOT_RETAIN" +%s`
                    if [[ $createDate -lt $olderThan ]]; then
                        if [[ $fileName != "" ]]; then
                            echo "$TIME: Deleting snapshot $fileName"
                            aws $aws_args s3 rm "${s3_uri_base}/$fileName"
                        fi
                    else
                        snapshots+=("$fileUrl")
                    fi
                else
                    snapshots+=("$fileUrl")
                fi
            done;

            if [ "$SNAPSHOT_METADATA" != "0" ]; then
                echo "$TIME: Uploading metadata"
                snapshotJson="[]"
                for url in ${snapshots[@]}; do
                    snapshotJson="$(echo $snapshotJson | jq ".+[\"$url\"]")"
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
