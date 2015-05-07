[![Build Status](https://travis-ci.org/boldfield/elasticsearch-manager.svg?branch=master)](https://travis-ci.org/boldfield/elasticsearch-manager)

# Elasticsearch-Manager

Elasticsearch-Manager provides both a commandline utility and libraries for performing
basic management activities on an Elasticsearch cluster.

For a list of all supported actions, please run: `$ elasticsearch-manager --help`

## Installation

```
gem install elasticsearch-manager
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
Discovering cluster members...

Restarting Elasticsearch on node: 127.0.0.1
Elasticsearch restarted on node: 127.0.0.1
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Cluster stabilized!
Continue with rolling restart of cluster? (yes/no) yes

Restarting Elasticsearch on node: 127.0.0.2
Elasticsearch restarted on node: 127.0.0.2
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Waiting for cluster to stabilize...
Cluster stabilized!
Continue with rolling restart of cluster? (yes/no) yes

Restarting current cluster master, continue? (yes/no) yes

Restarting Elasticsearch on node: 127.0.0.3
Elasticsearch restarted on node: 127.0.0.3
Waiting for cluster to stabilize...
Cluster stabilized!
```

