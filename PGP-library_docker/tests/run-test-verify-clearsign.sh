#!/bin/sh

docker run --rm -it -v `pwd`:/tests \
--network cyphernodenet eclipse-mosquitto:1.6-openssl /tests/test-verify-clearsign.sh