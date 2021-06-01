#!/bin/sh

NETWORK=cn-test-network
DATETIME=`date -u +"%FT%H%MZ"`
IMAGE=api-proxy-docker-test
BITCOIN_IMAGE=api-bitcoin-test

echo 'Stopping container'
docker stop `cat id-file.cid`
docker stop `cat bitcoin-id-file.cid`

echo 'Removing network'
docker network rm $NETWORK

rm -f *.cid

echo 'Removing image'
docker image rm $IMAGE
docker image rm $BITCOIN_IMAGE

echo "Done !"
