# Load Balanced RPC Nodes

This details two or more deployments of RPC nodes, and an nginx deployment to load balance them.

The node deployment shows running multiple RPC containers under a single domain (note the `count` in the deployment section). 
This deployment can be run multiple times to provide multiple domains, which can then be load balanced using the load balancer deployment (which can also be run as multiple containers, see `count` again). 
We don't map 26657 to port 80 in this instance, as all deployments would need to accept the same load balanced domain, which isn't possible currently.

The load balancer deployment uses a simple nginx container with a script to 
define dynamic upstream servers using an environment variable. See [tombeynon/nginx-dynamic-lb](https://github.com/tombeynon/nginx-dynamic-lb)

Currently adding/removing nodes will require updating the load balancer deployment
which should occur pretty quickly. 

Note that the RPC nodes would ideally be configured to sync with statesync nodes as detailed in the [main README](/README.md#statesync)
