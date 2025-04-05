#!/bin/bash

set -e

[ "$DEBUG" == "2" ] && set -x

SNAPSHOT_TIME="${SNAPSHOT_TIME:-00:00:00}"
SNAPSHOT_DAY="${SNAPSHOT_DAY:-*}"
SNAPSHOT_DIR="${SNAPSHOT_DIR:-$PROJECT_ROOT/data}"
SNAPSHOT_CMD="${SNAPSHOT_CMD:-$@}"
SNAPSHOT_PATH="${SNAPSHOT_PATH%/}"
SNAPSHOT_PREFIX="${SNAPSHOT_PREFIX:-$CHAIN_ID}"
SNAPSHOT_RETAIN="${SNAPSHOT_RETAIN:-2 days}"
SNAPSHOT_KEEP_LAST="${SNAPSHOT_KEEP_LAST:-2}"
SNAPSHOT_METADATA="${SNAPSHOT_METADATA:-1}"
SNAPSHOT_SAVE_FORMAT="${SNAPSHOT_SAVE_FORMAT:-$SNAPSHOT_FORMAT}"
valid_snapshot_formats=(tar tar.gz tar.zst)
# If not one of valid format values, set it to default value
if ! echo "${valid_snapshot_formats[@]}" | grep -qiw -- "$SNAPSHOT_SAVE_FORMAT"; then
  SNAPSHOT_SAVE_FORMAT=tar.gz
fi
# Actual valid values not documented
# 27 is default value
# 31 is max value mentioned in project issues
# Since value > 27 requires special handling on decompression
# Only 27 is allowed at the moment when enabled
# See https://github.com/facebook/zstd/blob/v1.5.2/programs/zstd.1.md for more info
valid_zstd_long_values=(27)
# If non empty string and invalid value detected
# Set to default value assuming long should be enabled
if [ -n "$ZSTD_LONG" ] && ! echo "${valid_zstd_long_values[@]}" | grep -qiw -- "$ZSTD_LONG"; then
  ZSTD_LONG=27
fi
zstd_extra_args=""
if [ -n "$ZSTD_LONG" ]; then
  zstd_extra_arg="--long=$ZSTD_LONG"
fi

# Validate SNAPSHOT_KEEP_LAST if set
if [[ -n "$SNAPSHOT_KEEP_LAST" && ! "$SNAPSHOT_KEEP_LAST" =~ ^[0-9]+$ ]]; then
  echo "ERROR: Invalid SNAPSHOT_KEEP_LAST value '$SNAPSHOT_KEEP_LAST'. Must be a non-negative integer."
  exit 1
fi

GCS_BUCKET_AND_PATH="${GCS_BUCKET_PATH#gs://}"
GCS_BUCKET="${GCS_BUCKET_AND_PATH%%/*}"
GCS_PATH="${GCS_BUCKET_AND_PATH#*/}"
GCS_PUBLIC_BASE_URL="https://storage.googleapis.com/${GCS_BUCKET_AND_PATH}"

is_gcs_object_public() {
  local object_path="$1"
  gsutil acl get "$object_path" 2>/dev/null | jq -e '.[] | select(.entity == "allUsers" and .role == "READER")' >/dev/null
}

make_gcs_file_public() {
  local file="$1"
  local object_uri="gs://${GCS_BUCKET_AND_PATH}/${file}"
  if [[ "$file" == gs://* ]]; then
    echo "ERROR: make_gcs_file_public was passed a full URI, expected filename only: '$file'" >&2
    return 1
  fi
  if ! is_gcs_object_public "$object_uri"; then
    echo "$TIME: Making ${object_uri} publicly accessible at ${GCS_PUBLIC_BASE_URL}/${file}"
    gsutil acl ch -u AllUsers:R "$object_uri"
  else
    echo "$TIME: $object_uri is already public, skipping acl ch"
  fi
}

TIME=$(date -u +%T)
DOW=$(date +%u)

echo "$TIME: Starting server"
echo "$TIME: Snapshot will run at $SNAPSHOT_TIME on day $SNAPSHOT_DAY"
exec $SNAPSHOT_CMD &
PID=$!

while true; do
    TIME=$(date -u +%T)
    DOW=$(date +%u)
    if ( [[ "$SNAPSHOT_DAY" == "*" ]] || [[ "$SNAPSHOT_DAY" == "$DOW" ]] ) && [[ "$SNAPSHOT_TIME" == "$TIME" ]] || [[ "$SNAPSHOT_ON_START" == "1" ]]; then
        # to avoid repeated snapshot triggers every loop
        SNAPSHOT_ON_START=0

        echo "$TIME: Stopping server"
        kill -15 $PID
        wait

        echo "$TIME: Running snapshot"
        aws_args="--endpoint-url ${S3_HOST}"
        storj_args="${STORJ_UPLINK_ARGS:--p 4 --progress=false}"
        s3_uri_base="s3://${SNAPSHOT_PATH}"
        storj_uri_base="sj://${SNAPSHOT_PATH}"
        timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
        s3_uri="${s3_uri_base}/${SNAPSHOT_PREFIX}_${timestamp}.${SNAPSHOT_SAVE_FORMAT}"
        storj_uri="${storj_uri_base}/${SNAPSHOT_PREFIX}_${timestamp}.${SNAPSHOT_SAVE_FORMAT}"

        SNAPSHOT_SIZE=$(du -sb $SNAPSHOT_DIR | cut -f1)

        if [ -n "$STORJ_ACCESS_GRANT" ]; then
          case "${SNAPSHOT_SAVE_FORMAT,,}" in
            tar.gz)   (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | gzip -1 | uplink cp $storj_args - "$storj_uri") 2>&1 | stdbuf -o0 tr '\r' '\n';;
            # Compress level can be set via `ZSTD_CLEVEL`, default `3`
            # No. of threads can be set via `ZSTD_NBTHREADS`, default `1`, `0` = detected no. of cpu cores
            tar.zst)  (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | zstd -c $zstd_extra_arg | uplink cp $storj_args - "$storj_uri") 2>&1 | stdbuf -o0 tr '\r' '\n';;
            # Catchall, assume to be tar
            *)        (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | uplink cp $storj_args - "$storj_uri") 2>&1 | stdbuf -o0 tr '\r' '\n';;
          esac
	elif [ "$GCS_ENABLED" == "1" ]; then
          # GCS
          gcs_uri="${GCS_BUCKET_PATH}/${SNAPSHOT_PREFIX}_${timestamp}.${SNAPSHOT_SAVE_FORMAT}"
          case "${SNAPSHOT_SAVE_FORMAT,,}" in
            tar.gz)   (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | gzip -1 | gsutil -q cp - "$gcs_uri") 2>&1 | stdbuf -o0 tr '\r' '\n';;
            tar.zst)  (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | zstd -c $zstd_extra_arg | gsutil -q cp - "$gcs_uri") 2>&1 | stdbuf -o0 tr '\r' '\n';;
            *)        (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | gsutil -q cp - "$gcs_uri") 2>&1 | stdbuf -o0 tr '\r' '\n' ;;
          esac
          make_gcs_file_public "$(basename "$gcs_uri")"
        else
          # AWS S3
          case "${SNAPSHOT_SAVE_FORMAT,,}" in
            tar.gz)   (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | gzip -1 | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE) 2>&1 | stdbuf -o0 tr '\r' '\n';;
            # Compress level can be set via `ZSTD_CLEVEL`, default `3`
            # No. of threads can be set via `ZSTD_NBTHREADS`, default `1`, `0` = detected no. of cpu cores
            tar.zst)  (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | zstd -c $zstd_extra_arg | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE) 2>&1 | stdbuf -o0 tr '\r' '\n';;
            # Catchall, assume to be tar
            *)        (tar c -C $SNAPSHOT_DIR . | pv -petrafb -i 5 -s $SNAPSHOT_SIZE | aws $aws_args s3 cp - "$s3_uri" --expected-size $SNAPSHOT_SIZE) 2>&1 | stdbuf -o0 tr '\r' '\n';;
          esac
	fi

        if [[ $SNAPSHOT_RETAIN != "0" || $SNAPSHOT_METADATA != "0" ]]; then
            # NOTE: s3Files lines are expected to be in this format: DATE TIME SIZE FILENAME
            # Where FILENAME is the *basename only* (e.g., "snapshot_2025-04-05.tar.gz"), not a full path.
            # This mirrors the AWS S3 and Storj uplink `ls` output format for compatibility.
            # For GCS, we explicitly strip the "gs://bucket/path/" prefix from the filename using `awk` substitution.
            if [ -n "$STORJ_ACCESS_GRANT" ]; then
              SNAPSHOT_METADATA_URL=$(uplink share --url --not-after=none ${storj_uri_base}/ | grep ^URL | awk '{print $NF}')
              readarray -t s3Files < <(uplink ls ${storj_uri_base}/ | grep "${SNAPSHOT_PREFIX}_" | awk '{print $2,$3,$4,$5}' | sort -d -k4,4)
            elif [ "$GCS_ENABLED" == "1" ]; then
              SNAPSHOT_METADATA_URL="${GCS_PUBLIC_BASE_URL}"
              readarray -t s3Files < <(gsutil ls -l "${GCS_BUCKET_PATH}/${SNAPSHOT_PREFIX}_"* 2>/dev/null \
                  | grep -v TOTAL \
                  | awk -v prefix="${GCS_BUCKET_PATH}/" '{
                      gsub(/Z$/, "", $2);
                      gsub(/T/, " ", $2);
                      sub(prefix, "", $3);
                      print $2, $1, $3
                  }')
            else
              readarray -t s3Files < <(aws $aws_args s3 ls "${s3_uri_base}/${SNAPSHOT_PREFIX}_")
            fi
            # For tracking how many snapshots we're keeping when setting SNAPSHOT_KEEP_LAST != 0
            snapshot_count="${#s3Files[@]}"
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
                if [ -n "$STORJ_ACCESS_GRANT" ]; then
		    fileUrl="${fileUrl}?download=1"
                fi
                if [[ "$SNAPSHOT_RETAIN" != "0" && "$snapshot_count" -gt "$SNAPSHOT_KEEP_LAST" ]]; then
                    olderThan=`date -d"-$SNAPSHOT_RETAIN" +%s`
                    if [[ $createDate -lt $olderThan ]]; then
                        if [[ -n "$fileName" ]]; then
                            echo "$TIME: Deleting snapshot $fileName"
                            if [ -n "$STORJ_ACCESS_GRANT" ]; then
                              uplink rm "${storj_uri_base}/$fileName"
                            elif [ "$GCS_ENABLED" == "1" ]; then
                              gsutil rm "${GCS_BUCKET_PATH}/${fileName}"
                            else
                              aws $aws_args s3 rm "${s3_uri_base}/$fileName"
                            fi
                            # decrement the snapshot count after deletion
                            ((snapshot_count--))
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
                if [ ${#snapshots[@]} -gt 0 ]; then
                  for url in "${snapshots[@]}"; do
                    snapshotJson="$(echo $snapshotJson | jq ".+[\"$url\"]")"
                  done
                else
                  echo "$TIME: No snapshots found, skipping snapshot.json upload"
                  continue
                fi
                if [ -n "$STORJ_ACCESS_GRANT" ]; then
                  echo $snapshotJson | jq '{chain_id: $c, snapshots: ., latest: $l}' \
                     --arg c "$CHAIN_ID" --arg l "${snapshots[-1]}" | \
                     uplink cp - "${storj_uri_base}/snapshot.json"
		  echo "=== Use the following as SNAPSHOT_JSON to restore the DCS Storj backup ==="
                  ##uplink share --url --not-after=none "${storj_uri_base}/snapshot.json" | grep ^URL | awk '{print $NF"?download=1"}'
		  echo "${SNAPSHOT_METADATA_URL%/}/snapshot.json?download=1"
		  echo "=== === ==="
                # GCS
                elif [ "$GCS_ENABLED" == "1" ]; then
                  echo $snapshotJson | jq '{chain_id: $c, snapshots: ., latest: $l}' \
                    --arg c "$CHAIN_ID" --arg l "${snapshots[-1]}" | \
                    gsutil -q cp - "${GCS_BUCKET_PATH}/snapshot.json"
                  make_gcs_file_public "snapshot.json"
                else
                  echo $snapshotJson | jq '{chain_id: $c, snapshots: ., latest: $l}' \
                     --arg c "$CHAIN_ID" --arg l "${snapshots[-1]}" | \
                     aws $aws_args s3 cp - "${s3_uri_base}/snapshot.json"
                fi
            fi
        fi

        echo "$TIME: Restarting server"
        exec $SNAPSHOT_CMD &
        PID=$!
        sleep 1s
    else
        if ! kill -0 $PID; then
            echo "$TIME: Process has died. Exiting"
            break;
        fi
    fi
done
