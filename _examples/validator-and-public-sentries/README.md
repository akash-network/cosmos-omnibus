# Validator and Public Sentries

> You can replace Akash with any other chain supported by the cosmos-omnibus project https://github.com/akash-network/cosmos-omnibus or is available via meta.json (see https://github.com/cosmos/chain-registry )

Sentry node is the internet facing node which serves the blocks to the validator as well as distributes them from the validator when validator signs them upon its turn in the tendermint consensus.  

Validator does not announce its existence to the network (`pex=false` /& `private_peer_ids`) and gets connected only to the sentry nodes.  
And ideally:
- validator should not be exposed on any other port than the P2P - 26656/tcp (default);
- the network link between sentries and validator should be in a private network;  

Sentry nodes always letting validator connect to them, unconditionally (`unconditional_peer_ids`).  
Sentry nodes can optionally expose additional ports, say RPC (26657/tcp), ideally you should place it behind the load balancer and throttle so to lower the usage / reduce possibility of DoS attack.  

This example shows 2 sentry nodes [statesynced from other nodes](../statesync), 
with a single private validator node which only connects to the sentries. 

You should know your sentry and validator node IDs beforehand, which involves controlling a `node_key.json` for each. 
The first time you run a node, if the `KEY_PATH` is set but doesn't exist on the storage provider, the `node_key.json` and `priv_validator_key.json` will be uploaded. You can use this method to obtain the private keys easily before re-configuring the nodes.

You should wait for the sentries to get up to date before running the validator, as it will statesync from those sentries. You can expand the sentry setup to as many nodes as required. Ideally some would be on other clouds for redundancy.

Akash is also very new - you should be prepared to run your validator on another cloud entirely at a moments notice. You should also setup a lot of monitoring. 


## Deployment process

1. Configure S3 compatible bucket with RW access (I suggest using Storj DCS).  
\- To use Storj DCS, add `- S3_HOST=https://gateway.storjshare.io` parameter.
1. Update the Akash SDL manifest files in this directory accordingly.
1. Deploy the sentry nodes first and then the validator.
1. Note down the following info from sentry nodes:  
\- sentry node ID (find in the deployment logs)  
\- sentry node URI and external port to 26656 (CLI: externalPort in lease-status / GUI: Forwarded ports in CloudMos).  
1. Update your validator Akash SDL manifest file with the sentry node ID, URIs and external port.
1. Deploy validator.
1. Note down validator node ID and update sentry SDL manifest file with it, update the sentry deployment.
1. Issue create-validator with your operator key and delegate enough stake for your validator to get into the active validator set.

## Working example

### validator should be only connected to the sentry nodes

```
$ curl -s http://mtaphuelj1bft4g83pg2d4onsg.ingress.europlots.com/net_info | jq -r '.result.peers[] | [ .node_info.id + "@" + .remote_ip + (.node_info.listen_addr | gsub(".*:"; ":")), (.node_info | .listen_addr, .moniker) ] | @csv' | column -t -s","
"687bdd7ea9a47965ecfcba3b902a207bbf919eb7@147.75.38.11:26656"  "tcp://0.0.0.0:26656"  "andy-sentry-01"
"1cba2d285861c412c817c0b2c8013aa64e3606fb@147.75.40.20:26656"  "tcp://0.0.0.0:26656"  "andy-sentry-02"
```

This is why it is important to:
- have more than 1 sentry node to avoid SPOF;
- monitor your sentry nodes are caught up with the tip of the chain;
- your validator is validating the blocks;

### Sentry gets connected to any node

```
$ curl -s http://gjmpnp4ag5e8v14rubecqafvt4.ingress.sandbox.ny.aksh.pw/net_info | jq -r '.result.peers[] | [ .node_info.id + "@" + .remote_ip + (.node_info.listen_addr | gsub(".*:"; ":")), (.node_info | .listen_addr, .moniker) ] | @csv' | column -t -s","
"20180c45451739668f6e272e007818139dba31e7@88.198.62.198:2020"    "tcp://0.0.0.0:2020"   "NotionalValidator"  
"30b8008d4ea5069a8724a0aa73833493efa88e67@65.108.140.62:26656"   "65.108.140.62:26656"  "Stake Frites (0     0.2)"
"1e8aaf3654887a05caeb0c1f73ce39e859e2f0c9@159.223.201.86:26656"  "tcp://0.0.0.0:26656"  "new"                
"02b5a74f0cc909045efe170da3cc5706de2c0be5@88.208.243.62:26656"   "tcp://0.0.0.0:26656"  "SmartStake"         
"9aa4c9097c818871e45aaca4118a9fe5e86c60e2@135.181.113.227:1506"  "tcp://0.0.0.0:1506"   "akash-api"          
"dda1f59957f767e20b0fc64b1c915b4799fc0cc5@159.223.201.93:26656"  "tcp://0.0.0.0:26656"  "new"                
"be0a6315cbac3a368ff394d314514264d8447057@141.94.139.219:26856"  "tcp://0.0.0.0:26856"  "ChainodeTech"       
"89757803f40da51678451735445ad40d5b15e059@169.155.44.92:26656"   "169.155.44.92:26656"  "Tendermint"         
"8d334fff41adeb68f186265d5f1f76614ef63d8d@185.183.35.91:26656"   "tcp://0.0.0.0:26656"  "rpc-nl-akash-farm"  
"ebc272824924ea1a27ea3183dd0b9ba713494f83@95.214.55.198:26696"   "95.214.55.198:26696"  "ao0a4qhtrglj"       
"6adc00bef235246c90757547d5f0703d6a548460@178.128.82.28:26656"   "tcp://0.0.0.0:26656"  "witval"             
"00cd3ff3d7309fb933a4c3f518a46b4730fec3ab@147.75.38.11:26656"    "tcp://0.0.0.0:26656"  "andy-validator-01" 
```

## Parameters explained

- `PEX` - set to `true` enables peer exchange reactor (gossip protocol), otherwise only the list of nodes in the `persistent_peers` list are available for connection. Should be **disabled** on the validator running behind sentry nodes.
- `PRIVATE_PEER_IDS` - these node IDs will not be gossiped at all times, when `PEX=true`. Should be set to the validator node ID on sentry nodes.
- `UNCONDITIONAL_PEER_IDS` - list of nodes IDs which can always be connected to the node that sets it. Should be set to the valiator node ID on sentry. And to the sentry node ID on the validator.
- `ADDR_BOOK_STRICT` - set to `false` if some of the nodes are on a LAN IP.

## Additional information

- [Sentry node architecture overview](https://forum.cosmos.network/t/sentry-node-architecture-overview/454)
- [Validator and Private Sentries](https://github.com/akash-network/cosmos-omnibus/tree/master/_examples/validator-and-private-sentries)
- [Validator and Public Sentries](https://github.com/akash-network/cosmos-omnibus/tree/master/_examples/validator-and-public-sentries)
- [Sentry Nodes (DDOS Protection)](https://hub.cosmos.network/main/validators/security.html#sentry-nodes-ddos-protection)

