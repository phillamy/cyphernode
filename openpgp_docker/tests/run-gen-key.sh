#!/bin/sh

docker run --rm -v `pwd`/../scripts/gen-key.sh:/gen-key.sh -v `pwd`/../data:/data -v `pwd`/../keys:/.gnupgp -v `pwd`/../../dist/cyphernode/logs:/cnlogs --network cyphernodenet  --name cn-pgp pgp-mosquitto:1.0 `id -u`:`id -g` ./gen-key.sh
