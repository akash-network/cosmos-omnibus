# Statesync

To statesync a node, you need at least 2x existing nodes with `state-sync.snapshot-interval` set to a non-zero value (`{NAMESPACE}_SNAPSHOT_INTERVAL`). 

This example includes 2 deploy files - `snapshot-deploy.yml` for the two snapshotting nodes, and `statesync-deploy` for a third statesynced node. 

We use the `STATESYNC_RPC_SERVERS` option which automatically configures statesync from the first node's RPC server, and configures both as the `statesync.rpc-servers`.

Alternatively you can configure statesync manually using the [options in the docs](/README.md#Statesync)

