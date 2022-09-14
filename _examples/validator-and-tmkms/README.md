# Validator and TMKMS

This example outlines how to run a node on Akash, connected to a TMKMS signer hosted elsewhere. This allows you to host the sensitive key material anywhere you trust with TMKMS, while running the actual blockchain node on Akash. It also allows quick and easy switching of the node used for signing, either between Akash deployments or between an Akash deployment and a node running elsewhere.

The ideal scenario would be as follows:

- TMKMS hosted on a secure server you trust. This could be at your home/office if you have reliable internet and servers, or in a data center you trust.
- A node running on Akash, which the TMKMS signer connects to to sign blocks.
- A backup node running on Akash, which the TMKMS signer can be switched to manually if required. You should use a different provider for the second node.
- A second backup node running in another data center which can be used as a secondary backup option.

This setup would also work well with a [Horcrux cluster](https://github.com/strangelove-ventures/horcrux), which could be implemented in a similar fashion without too much effort.

## Prerequisites

You should have a clear understanding of how TMKMS works. Ideally you run a validator already, and have already switched to TMKMS for your operations. Alternatively you run a validator but don't use TMKMS yet; in which case it would be best for you to setup TMKMS with your existing setup first, before migrating to Akash.

Some excellent guides on using TMKMS can be found at the following links:

- [TMKMS docs](https://github.com/iqlusioninc/tmkms)
- [Osmosis TMKMS setup guide](https://docs.osmosis.zone/developing/keys/tmkms.html#setup-tmkms)
- [Lavender Five notes](https://gist.github.com/dylanschultzie/c7c4eed531df0f004a50c5395e1604b3)
- [King Nodes Cosmos Tools guide](https://github.com/nullmames/cosmos-tools/tree/main/tmkms)

Once you have this setup, you should have a TMKMS signer, connected to an existing node. You should understand how to change the node the signer is connecting to, and you should have secured your key material.

## Caveats

There are currently two main caveats to using TMKMS with nodes hosted on Akash. These will be resolved with updates in the near future.

1. Right now Akash cannot restrict port access to certain IP addresses. We need the RPC and `priv-validator-laddr` ports to be restricted to your signer and monitoring servers only. __We will use a proxy container running [Stunnel](https://github.com/ovrclk/stunnel-proxy) to TLS encrypt the connections to these ports__.
1. Currently an Akash deployment using Persistent Storage cannot be updated. This presents an issue with TMKMS as when you set the `priv-validator-laddr` config, the node will not start until the signer is connected. This means you will be missing blocks while you wait for the node to sync, since you can't sync the node _then_ update the deployment to enable remote signing. Bootstrapping the node with Statesync is the fastest way to get a node up and running. Deployments that do not use Persistent Storage can update their deployment by changing the image/tag.

## Preparation

1. You should already have TMKMS setup and signing using nodes on typical servers so you understand the process.
1. Ensure you understand how the Stunnel proxy container works by referring to the project's [README](https://github.com/ovrclk/stunnel-proxy).
1. Generate a PSK (pre shared key) which will be used to encrypt the connection between the Stunnel proxies: `openssl rand 1024 | tr -dc 'a-zA-Z0-9' | head -c32 ; echo`.
1. Make sure you replace the example PSK (`DmtaC6N3HOWFkJZpNZs2dkabFT5yQONw`) in the examples with your PSK generated in the previous step!

## Process

1. Spin up a node on Akash with persistent storage, using the [example deploy.yml](./deploy.yml). A [Stunnel proxy container](https://github.com/ovrclk/stunnel-proxy) is deployed alongside the node to prevent unauthorised access to the RPC and Signer ports. Note that the `priv-validator-laddr` config is already configured, which means the node won't start until the signer is connected. Also note we use Statesync here to ensure the node starts as quickly as possible.
1. Obtain the URL to access the `36658` remote signer port from the proxy deployment. The node's `26658` port is only exposed to the proxy container and is not accessible externally. Similarly grab the `36657` RPC proxy port which is proxying the private `26657` port.
1. Setup a second [Stunnel proxy container](https://github.com/ovrclk/stunnel-proxy) in client mode on the same server as your TMKMS signer. You can also [setup Stunnel manually](https://www.stunnel.org/howto.html) instead of using the container implementation. Configure the RPC and Signer services, ensuring the `_CONNECT` variables are pointing to the `host:port` returned by step 2. The `_ACCEPT` variables define the port that will be exposed on your server. See the [example docker-compose.yml](./docker-compose.yml) for an example of how this might look.
1. Update KMS to point to the port you exposed on the Stunnel proxy container for the Signer service. You will stop signing, but the node should recognise the connection (proxied through Stunnel) and start to statesync.
1. Once the node has synced state and caught up with the tip of the blockchain, you will see TMKMS start to sign.
1. You are now signing blocks using a node hosted on Akash, with your key material secured in TMKMS, and all connections secured by Stunnel's TLS encryption.
1. You should also be able to access the Akash node's RPC using the port you defined in the `_ACCEPT` for the Stunnel RPC service, which can be used for monitoring purposes.

Note the [example deploy.yml](./deploy.yml) uses Persistent Storage to ensure any container restarts retain the storage. This may or may not be necessary depending on your use case.

## Use in Production

This solution is very suitable for production use, since your key material is kept secure on your own servers, and the communication between the node on Akash and TMKMS is encrypted by your PSK. TMKMS could easily be replaced by an MPC signer such as [Horcrux](https://github.com/strangelove-ventures/horcrux) to secure your key material even further, and to provide fault tolerance across multiple nodes.

Switching out the node is as simple as updating the Stunnel client container's `*_CONNECT` environment variable and restarting the proxy. TMKMS is connected to the proxy and doesn't need a restart in these circumstances.

Assuming a reliable Statesync configuration, a node can be recreated on Akash and signing again in 10-20 minutes. TMKMS will pick up the connection once it recovers without intervention.
