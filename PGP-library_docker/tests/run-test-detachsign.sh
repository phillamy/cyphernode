#!/bin/sh

docker run --rm -it -v `pwd`/test-detachsign.sh:/test-detachsign.sh \
--network cyphernodenet gpg-test:1.0 `id -u`:`id -g` /test-detachsign.sh