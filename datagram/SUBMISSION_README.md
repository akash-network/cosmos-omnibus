# 🚀 Datagram Network - Akash Network Submission

## 📋 Submission Overview

This directory contains the complete Datagram Network submission for the Akash Network's official apps repository (`akash-network/cosmos-omnibus`).

## 📁 Files Included

### Core Files
- **`README.md`** - Following the Jackal format with version table
- **`deploy.yml`** - Akash deployment configuration (tested and working)
- **`build.yml`** - Build configuration for custom deployments
- **`docker-compose.yml`** - Docker Compose example for local testing

## ✅ Key Information

| Component | Value |
|-----------|-------|
| **Docker Image** | `virgilbb/datagram-node:amd64` |
| **Version** | v1.1.4 |
| **Repository** | https://github.com/VirgilBB/datagram-nodeops |
| **Architecture** | AMD64/x86_64 |
| **Resources** | 200m CPU, 256MB RAM, 512MB Storage |
| **Ports** | 3000, 4000 |

## 🔧 Environment Variables

- `DATAGRAM_LICENSE_KEY` - Required: Get from demo.datagram.network
- `NODE_NAME` - Optional: Custom node identifier
- `LOG_LEVEL` - Optional: Logging level (default: info)

## 🎯 License Key Process

1. Get API key at: `demo.datagram.network/account?tab=apis`
2. Get license key at: `demo.datagram.network/wallet?tab=licenses`

## ✅ Testing Status

- **NodeOps Template**: ✅ COMPLETE and TESTED
- **Docker Image**: ✅ WORKING (`virgilbb/datagram-node:amd64`)
- **Akash Deployment**: ✅ TESTED and FUNCTIONAL
- **Resource Requirements**: ✅ VERIFIED (200m CPU, 256MB RAM)

## 🚀 Ready for Submission

All files are prepared and ready for the Akash Network pull request submission!

---

**Next Steps:**
1. Fork `akash-network/cosmos-omnibus`
2. Copy these files to the `datagram/` directory in the forked repo
3. Create pull request to the main repository
