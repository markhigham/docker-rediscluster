Behind the proxy stuff
- Set HTTP_PROXY and HTTPS_PROXY before `vagrant up`

from inside the vagrant box

`sudo visudo`

Defaults        env_keep="http_proxy https_proxy noproxy"

edit .bashrc or .profile to export http_proxy and https_proxy

docker-rediscluster
===================

Sets up a disposable redis cluster for testing sentinel failover.

Topology
--------

redis_0 - master

redis_1 - slave of redis_0

sentinel_0

sentinel_1

sentinel_2

The sentinels are configured with a "testing" instance with the following properties -

```
down-after-milliseconds 1000
failover-timeout 1000
parallel-syncs 1
```

Set up
------

Install the redis-cli maybe using apt-get install redis-server

```
docker pull redis
docker pull joshula/redis-sentinel
```

Run
---

provision_docker_redis_cluster.sh

Remove cluster
--------------

remove_docker_redis_cluster.sh

Play with it
------------

Attach to a sentinel

```
sudo docker attach sentinel_1ewxexi
```

Pause/Unpause redis instances

```
sudo docker pause redis_0
sudo docker unpause redis_0
```

