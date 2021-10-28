#!/bin/sh


# You can edit JMeter test file (.jmx) with the JMeter GUI - Also add an entry in your host file : "cn-test 	127.0.0.1".
# Port 8888 is mapped so you can test your test file from your host without changing host name in the JMX file 


NETWORK=cn-test-network
DATETIME=`date -u +"%FT%H%MZ"`
IMAGE=api-proxy-docker-test
BITCOIN_IMAGE=api-bitcoin-test
JMETER_IMAGE=jmeter-gui:5.4.1

echo Setting up to test `pwd` on $DATETIME

create_test_network()
{
  local network=$(docker network ls | grep cn-test-network );

  if [[ ! $network =~ 'cn-test-network' ]]; then
    docker network create $NETWORK
  else
    echo "Network found"
  fi    
} 

build_proxy()
{
  local image=$(docker image ls | grep api-proxy-docker-test );

  if [[ ! $image =~ 'api-proxy-docker-test' ]]; then
    docker build -f ../../Dockerfile --no-cache -t $IMAGE ../..
  else
    echo "Proxy image found"
  fi
}

build_bitcoin()
{
  local image=$(docker image ls | grep api-bitcoin-test );

  if [[ ! $image =~ 'api-bitcoin-test' ]]; then
    docker build --no-cache --build-arg ARCH=x86_64 -t $BITCOIN_IMAGE ../../../../dockers/bitcoin-core
  else
    echo "Bitcoin core image found"
  fi
}

build_jmeter()
{
  local image=$(docker image ls | grep jmeter-gui);

  if [[ ! $image =~ 'jmeter-gui' ]]; then
    docker build -f Dockerfile-JMeter-GUI --no-cache -t $JMETER_IMAGE . 
  else
    echo "JMeter image found"
  fi
}

create_test_network
build_proxy
build_bitcoin
build_jmeter

#Run proxy
docker run -d --rm -v `pwd`/../cyphernode/logs:/cnlogs -v `pwd`/../cyphernode/proxy:/proxy/db --network $NETWORK --name cn-test --cidfile=id-file.cid --env-file ./env.properties $IMAGE `id -u`:`id -g` ./startproxy.sh

#Run bitcoind
docker run -d --rm --cidfile=bitcoin-id-file.cid --network $NETWORK --name bitcoin --mount type=bind,source=`pwd`,target=/.bitcoin $BITCOIN_IMAGE `id -u`:`id -g` bitcoind

#Run JMeter GUI container - connect with VNC
docker run --cidfile=jmeter-id-file.cid -d --network cn-test-network --rm -p 5900:5900 --mount type=bind,source=`pwd`,target=/test jmeter-gui:5.4.1

echo "Containers are ready.  Use VNC to connect to JMeter GUI to test - vnc://localhost:5900 passwd: jmeter"
