#!/bin/sh

NETWORK=cn-test-network
IMAGE=api-proxy-docker-test
BITCOIN_IMAGE=api-bitcoin-test
JMETER_IMAGE=jmeter-gui:5.4.1

echo 'Stopping containers'
docker stop `cat id-file.cid`
docker stop `cat bitcoin-id-file.cid`
docker stop `cat jmeter-id-file.cid`

rm -f *.cid

echo "Done !"
