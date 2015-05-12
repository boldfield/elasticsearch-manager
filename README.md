[![Build Status](https://travis-ci.org/boldfield/elasticsearch-manager.svg?branch=master)](https://travis-ci.org/boldfield/elasticsearch-manager)

# Elasticsearch-Manager

Elasticsearch-Manager provides both a commandline utility and libraries for performing
basic management activities on an Elasticsearch cluster.

For a list of all supported actions, please run: `$ elasticsearch-manager --help`

## Installation

```
gem install elasticsearch-manager
```

## List IPs for all cluster members
```
$ elasticsearch-manager --cluster-hostname elasticsearch.example.com \
                        --port 9200 status \
                        list-nodes
10.0.0.3 -- master
10.0.0.1
10.0.0.2
```

## Display the count of all shard states for each node in the cluster
```
$ elasticsearch-manager --cluster-hostname elasticsearch.example.com \
                        --port 9200 status \
                        shard-state
10.0.0.1:   STARTED: 8       INITIALIZING: 0    RELOCATING: 0
10.0.0.2:   STARTED: 8       INITIALIZING: 0    RELOCATING: 1
10.0.0.3:   STARTED: 7       INITIALIZING: 1    RELOCATING: 0
```

## Check the current status of a cluster

```
$ elasticsearch-manager --cluster-hostname elasticsearch.example.com \
                        --port 9200 status \
                        status
The Elasticsearch cluster is currently: green
```

## Perform a rolling restart of a cluster
```
$ elasticsearch-manager --cluster-hostname elasticsearch.example.com \
                        --port 9200 status \
                        rolling-restart
Continue with rolling restart of cluster? (y/n) y

Restarting Elasticsearch on node: 10.0.0.1
Elasticsearch restarted on node: 10.0.0.1
Waiting for node to become available...
Node back up!
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Cluster stabilized!
Continue with rolling restart of cluster? (y/n) y

Restarting Elasticsearch on node: 10.0.0.2
Elasticsearch restarted on node: 10.0.0.2
Waiting for node to become available...
Waiting for node to become available...
Node back up!
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Cluster stabilized!

Restarting current cluster master, continue? (y/n) y

Restarting Elasticsearch on node: 10.0.0.3
Elasticsearch restarted on node: 10.0.0.3
Waiting for node to become available...
Waiting for node to become available...
Waiting for node to become available...
Waiting for node to become available...
Node back up!
Waiting for cluster to stabilize...
Cluster stabilized!
```

## Disable routing allocation on the cluster
```
$ elasticsearch-manager --cluster-hostname elasticsearch.example.com \
                        --port 9200 status \
                        disable-routing
Disabling shard routing allocation... disabled!
```

## Enable routing allocation on the cluster
```
$ elasticsearch-manager --cluster-hostname elasticsearch.example.com \
                        --port 9200 status \
                        enable-routing
Enabling shard routing allocation... enabled!
```
