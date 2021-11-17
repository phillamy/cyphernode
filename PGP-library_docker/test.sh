#!/bin/sh

docker run --rm -it -v `pwd`/testmsg.sh:/testmsg.sh \
--network cyphernodenet eclipse-mosquitto:1.6-openssl /testmsg.sh