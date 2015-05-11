# Releases

## Current

## v0.1.2
- Added new actions
  + list-nodes
  + shard-state
  + disable-routing
  + enable-routing
- Begun introducing flag to print verbose messaging
- Now updating cluster-wide `node_concurrent_recoveries` setting equal
  to the number of shards present on the node being restarted
- Began raising Elasitcsearch::Manager::ApiError when API request exceptions occur

## v0.1.1
- Add required user confirmation between node restarts
- Add parameterized sleep interval between stabilization checks
- Guarantee the current master is restarted last
- Add wait for node availability before re-enabling route allocation

## v0.1.0
- Initial release of elasticsearch manager
- Supported rolling-restart of cluster and printing simple cluster status (green/yellow/red)
