#!/bin/bash

# hardcoded eth1 interface - this may not work for you
DOCKER_IP=$(ifconfig eth1 | grep 'inet addr:' | cut -d: -f2  | awk '{ print $1}')

echo "DOCKER IP : $DOCKER_IP"

# create two redis instances
docker run -v $PWD/redis.conf:/usr/local/etc/redis --name redis_0 -t -d -i -p $DOCKER_IP:6379:6379 redis /usr/local/etc/redis/redis_0.conf
docker run -v $PWD/redis.conf:/usr/local/etc/redis --name redis_1 -t -d -i -p $DOCKER_IP:6389:6379 redis /usr/local/etc/redis/redis_1.conf
docker run -v $PWD/redis.conf:/usr/local/etc/redis --name redis_2 -t -d -i -p $DOCKER_IP:6399:6379 redis /usr/local/etc/redis/redis_2.conf

#get master ip
REDIS_0_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis_0)
REDIS_1_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis_1)
REDIS_2_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis_2)

echo "REDIS_0_IP : $REDIS_0_IP"
echo "REDIS_1_IP : $REDIS_1_IP"
echo "REDIS_2_IP : $REDIS_2_IP"

# start up the sentinels
docker run --name sentinel_0 -d -p $DOCKER_IP:26379:26379 sentinel --sentinel announce-ip $DOCKER_IP --sentinel announce-port 26379 --protected-mode no

#get sentinel ips
SENTINEL_0_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' sentinel_0)

echo "SENTINEL_0_IP : $SENTINEL_0_IP"

redis-cli -h $REDIS_1_IP -p 6379 slaveof $REDIS_0_IP 6379
redis-cli -h $REDIS_2_IP -p 6379 slaveof $REDIS_0_IP 6379


redis-cli -h $DOCKER_IP -p 26379 sentinel monitor testing $REDIS_0_IP 6379 2
redis-cli -h $DOCKER_IP -p 26379 sentinel set testing down-after-milliseconds 1000
redis-cli -h $DOCKER_IP -p 26379 sentinel set testing failover-timeout 1000
redis-cli -h $DOCKER_IP -p 26379 sentinel set testing parallel-syncs 1

