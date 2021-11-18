#!/bin/sh

docker run --rm -it -v `pwd`/test-clearsign.sh:/test-clearsign.sh \
--network cyphernodenet eclipse-mosquitto:1.6-openssl /test-clearsign.sh