#!/bin/sh

docker run --rm -it -v `pwd`:/tests \
--network cyphernodenet gpg-test:1.0 `id -u`:`id -g` /tests/test-verify-clearsign.sh