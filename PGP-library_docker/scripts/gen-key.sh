#!/bin/sh

# Perform unattended key generation
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
#
# docker run --rm -v `pwd`/gen-key.sh:/gen-key.sh -v `pwd`/../data:/data -v `pwd`/../keys:/.gnupgp -v `pwd`/../../dist/cyphernode/logs:/cnlogs --network cyphernodenet  --name cn-pgp pgp-mosquitto:1.0 `id -u`:`id -g` ./gen-key.sh

gpg --batch --gen-key /data/key-definition.txt
