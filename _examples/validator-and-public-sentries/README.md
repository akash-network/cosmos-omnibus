# Validator and Public Sentries

This example shows 2 sentry nodes [statesynced](../statesync) from other controlled nodes, 
with a single private validator node which only connects to the sentries. 

You should know your sentry and validator node IDs beforehand, which involves controlling a `node_key.json` for each. 
The first time you run a node, if the `KEY_PATH` is set but doesn't exist on the storage provider, the `node_key.json` and `priv_validator_key.json` will be uploaded. You can use this method to obtain the private keys easily before re-configuring the nodes.

You should wait for the sentries to get up to date before running the validator, as it will statesync from those sentries. You can expand the sentry setup to as many nodes as required. Ideally some would be on other clouds for redundancy.

Akash is also very new - you should be prepared to run your validator on another cloud entirely at a moments notice. You should also setup a lot of monitoring. 
