#!/bin/sh


# You can edit JMeter test file (.jmx) with the JMeter GUI - Also add an entry in your host file : "cn-test 	127.0.0.1".
# Port 8888 is mapped so you can test your test file from your host without changing host name in the JMX file 


NETWORK=cn-test-network
DATETIME=`date -u +"%FT%H%MZ"`
IMAGE=api-proxy-docker-test
BITCOIN_IMAGE=api-bitcoin-test

echo Setting up to test `pwd` on $DATETIME

docker network create $NETWORK 

#Build proxy
docker build -f ../../Dockerfile --no-cache -t $IMAGE ../..

#Build bitcoin
docker build --no-cache --build-arg ARCH=x86_64 -t $BITCOIN_IMAGE ../../../../dockers/bitcoin-core

#Run proxy
docker run -p 8888:8888 -d --rm -v `pwd`/../cyphernode/logs:/cnlogs -v `pwd`/../cyphernode/proxy:/proxy/db --network $NETWORK --name cn-test --cidfile=id-file.cid --env-file ./env.properties $IMAGE `id -u`:`id -g` ./startproxy.sh

#Run bitcoind
docker run -d --rm --cidfile=bitcoin-id-file.cid --network $NETWORK --name bitcoin --mount type=bind,source=`pwd`,target=/.bitcoin $BITCOIN_IMAGE `id -u`:`id -g` bitcoind

echo "Containers are ready.  You can use JMeter GUI to test"
