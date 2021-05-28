#!/bin/sh


# You can edit JMeter test file api-auth-docker.jmx with the JMeter GUI - Also add an entry in your host file : "cn-test 	127.0.0.1".
# Port 80 is mapped so you can test your test file from your host without changing host name in the JMX file 


NETWORK=cn-test-network
DATETIME=`date -u +"%FT%H%MZ"`

echo Setting up to test `pwd` on $DATETIME

docker network create $NETWORK 

docker build --no-cache -t api-auth-docker-test ..

docker run -p 80:80 -d --rm --network $NETWORK --name cn-test --cidfile=id-file.cid --env-file ../env.properties api-auth-docker-test `id -u`:`id -g` 

# Running test with script file
#docker exec -it `cat id-file.cid` sh /etc/nginx/conf.d/test.sh

#JMeter
docker run --rm --network $NETWORK --mount type=bind,source=`pwd`,target=/test alpine/jmeter:5.4.1 -n -t /test/api-auth-docker.jmx -e -l /test/results/results-$DATETIME.jtl -f -o /test/results/test-results-$DATETIME 

docker stop `cat id-file.cid`

docker network rm $NETWORK

rm -f id-file.cid

echo "HTML Test and Report information for this run can be seen here: `pwd`/results/test-results-$DATETIME/index.html"
