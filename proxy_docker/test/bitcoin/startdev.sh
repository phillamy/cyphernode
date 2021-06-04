#!/bin/sh


# You can edit JMeter test file (.jmx) with the JMeter GUI - Also add an entry in your host file : "cn-test 	127.0.0.1".
# Port 8888 is mapped so you can test your test file from your host without changing host name in the JMX file 


NETWORK=cn-test-network
DATETIME=`date -u +"%FT%H%MZ"`
IMAGE=api-proxy-docker-test
BITCOIN_IMAGE=api-bitcoin-test
JMETER_IMAGE=jmeter-gui:5.4.1

echo Setting up to test `pwd` on $DATETIME

docker network create $NETWORK 

#Build proxy
docker build -f ../../Dockerfile --no-cache -t $IMAGE ../..

#Build bitcoin
docker build --no-cache --build-arg ARCH=x86_64 -t $BITCOIN_IMAGE ../../../../dockers/bitcoin-core

#Build JMeter GUI
docker build -f Dockerfile-JMeter-GUI --no-cache -t $JMETER_IMAGE . 

#Run proxy
docker run -p 8888:8888 -d --rm -v `pwd`/../cyphernode/logs:/cnlogs -v `pwd`/../cyphernode/proxy:/proxy/db --network $NETWORK --name cn-test --cidfile=id-file.cid --env-file ./env.properties $IMAGE `id -u`:`id -g` ./startproxy.sh

#Run bitcoind
docker run -d --rm --cidfile=bitcoin-id-file.cid --network $NETWORK --name bitcoin --mount type=bind,source=`pwd`,target=/.bitcoin $BITCOIN_IMAGE `id -u`:`id -g` bitcoind

#Run JMeter GUI container - connect with VNC
docker run --cidfile=jmeter-id-file.cid -d --network cn-test-network --rm -p 5900:5900 --mount type=bind,source=`pwd`,target=/test jmeter-gui:5.4.1

echo "Containers are ready.  Use VNC to connect to JMeter GUI to test - vnc://localhost:5900 passwd: jmeter"
