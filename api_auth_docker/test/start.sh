#!/bin/sh

docker network create test-network

docker build -f ./Dockerfile --no-cache -t api-auth-docker-test ..

docker run -d --rm --network test-network --cidfile=id-file.cid --env-file ../env.properties api-auth-docker-test `id -u`:`id -g` 

docker exec -it `cat id-file.cid` sh /etc/nginx/conf.d/test.sh

#JMeter
docker run --rm --network test-network --mount type=bind,source=`pwd`,target=/test alpine/jmeter:5.4.1 -n -t /test/api_auth_docker.jmx -e -l results.jtl -f -o test-results.out 

docker stop `cat id-file.cid`

docker network rm test-network

rm -f id-file.cid


