#!/bin/sh

docker run --rm -it -v `pwd`/test-clearsign.sh:/test-clearsign.sh \
--network cyphernodenet gpg-test:1.0 `id -u`:`id -g` /test-clearsign.sh