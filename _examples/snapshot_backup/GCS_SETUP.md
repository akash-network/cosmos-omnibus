# 📦 Setting Up Google Cloud Storage for Snapshot Backups

This guide walks you through creating a Google Cloud Storage (GCS) bucket, configuring a service account, and generating a key file for automated snapshot backups using the [cosmos-omnibus](https://github.com/ovrclk/cosmos-omnibus) container.

---

## ⚙️ Prerequisites

Install the Google Cloud SDK:

```
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
apt update && apt install -y google-cloud-cli
```

---

## 🪣 1. Create a GCS Bucket

```
export GCS_PROJECT_ID="your-project-id"
export GCS_BUCKET="your-snapshot-bucket"

gcloud config set project "$GCS_PROJECT_ID"
gcloud storage buckets create gs://$GCS_BUCKET --location=us-central1
```

---

## 📆 2. (Optional) Set Lifecycle Rules

To auto-delete old snapshots (e.g. after 60 days):

```
cat > lifecycle.json <<EOF
{
  "rule": [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 60}
    }
  ]
}
EOF

gsutil lifecycle set lifecycle.json gs://$GCS_BUCKET
```

---

## 👤 3. Create a Service Account

```
gcloud iam service-accounts create my-akash-rpc-bkp-svc \
  --description="Backup service account for GCS uploads" \
  --display-name="RPC Backup Service"
```

---

## 🔐 4. Grant Permissions

To allow uploading and updating files (like `snapshot.json`), grant `objectAdmin`:

```
gsutil iam ch \
  serviceAccount:my-akash-rpc-bkp-svc@${GCS_PROJECT_ID}.iam.gserviceaccount.com:objectAdmin \
  gs://$GCS_BUCKET
```

---

## 🗝 5. Generate and Download the Service Account Key

```
gcloud iam service-accounts keys create gcs-backup-key.json \
  --iam-account=my-akash-rpc-bkp-svc@${GCS_PROJECT_ID}.iam.gserviceaccount.com
```

This creates a `gcs-backup-key.json` file that you'll mount into the container.

---

## 🧪 6. Example Docker Compose Setup

> When testing **key backup/restore**, make sure `KEY_PATH` starts with `gs://`:
>
> ```
> - KEY_PATH=gs://your-bucket/key-backups
> ```

### Example service config:

```
  node:
    image: ghcr.io/akash-network/cosmos-omnibus:v1.2.12-akash-v0.38.1
    restart: no
    environment:
      - CHAIN_JSON=https://raw.githubusercontent.com/akash-network/net/main/mainnet/meta.json
      # GCS Backup Configuration
      - GCS_ENABLED=1
      - GCS_BUCKET_PATH=gs://your-bucket/akash/snapshots
      - GCS_KEY_FILE=/root/gcs-backup-key.json
      - SNAPSHOT_KEEP_LAST=2  # always keep at least 2 snapshots
      #- SNAPSHOT_ON_START=1   # optional: trigger immediate snapshot on container start
      # For snapshot restore
      #- SNAPSHOT_JSON=https://storage.googleapis.com/your-bucket/akash/snapshots/snapshot.json
      # Key backup/restore path
      - KEY_PATH=gs://your-bucket/akash/node1-key-backups
    volumes:
      - /root/akash-node:/root/.akash
      - /root/gcs-backup-key.json:/root/gcs-backup-key.json:ro
```

---

## ✅ Done!

Your container can now automatically upload snapshots and `snapshot.json` metadata to GCS — and also restore from GCS using the same service account.
