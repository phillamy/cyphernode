#!/bin/sh


# You can edit JMeter test file (.jmx) with the JMeter GUI - Also add an entry in your host file : "cn-test 	127.0.0.1".
# Port 8888 is mapped so you can test your test file from your host without changing host name in the JMX file 


NETWORK=cn-test-network
DATETIME=`date -u +"%FT%H%MZ"`

echo Setting up to test `pwd` on $DATETIME

docker network create $NETWORK 

docker build -f ../Dockerfile --no-cache -t proxy-docker-test ..

docker run -p 8888:8888 -d --rm -v `pwd`/cyphernode/logs:/cnlogs -v `pwd`/cyphernode/proxy:/proxy/db --network $NETWORK --name cn-test --cidfile=id-file.cid --env-file ../env.properties proxy-docker-test `id -u`:`id -g` ./startproxy.sh

#JMeter
docker run --rm --network $NETWORK --mount type=bind,source=`pwd`,target=/test alpine/jmeter:5.4.1 -n -t /test/proxy_docker.jmx -e -l /test/results/results-$DATETIME.jtl -f -o /test/results/test-results-$DATETIME 

echo 'Stopping container'
docker stop `cat id-file.cid`

echo 'Removing network'
docker network rm $NETWORK

rm -f id-file.cid

echo 'Removing image proxy-docker-test'
docker image rm proxy-docker-test

echo "HTML Test and Report information for this run can be seen here: `pwd`/results/test-results-$DATETIME/index.html"
