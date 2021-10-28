#!/bin/sh

# You can edit JMeter test file (.jmx) with the JMeter GUI

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
docker run -d --rm -v `pwd`/../cyphernode/logs:/cnlogs -v `pwd`/../cyphernode/proxy:/proxy/db --network $NETWORK --name cn-test --cidfile=id-file.cid --env-file ./env.properties $IMAGE `id -u`:`id -g` ./startproxy.sh

#Run bitcoind
docker run -d --rm --cidfile=bitcoin-id-file.cid --network $NETWORK --name bitcoin --mount type=bind,source=`pwd`,target=/.bitcoin $BITCOIN_IMAGE `id -u`:`id -g` bitcoind

#JMeter
docker run --rm --network $NETWORK --mount type=bind,source=`pwd`,target=/test alpine/jmeter:5.4.1 -n -t /test/proxy-bitcoin.jmx -e -l /test/results/results-$DATETIME.jtl -f -o /test/results/test-results-$DATETIME 

echo 'Stopping container'
docker stop `cat id-file.cid`
docker stop `cat bitcoin-id-file.cid`

echo 'Removing network'
docker network rm $NETWORK

rm -f *.cid

echo 'Removing image'
docker image rm $IMAGE
docker image rm $BITCOIN_IMAGE

echo "HTML Test and Report information for this run can be seen here: `pwd`/results/test-results-$DATETIME/index.html"
