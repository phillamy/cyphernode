#!/bin/sh

# Perform unattended key generation
# https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
#
# docker run --rm -v `pwd`/gen-key.sh:/gen-key.sh -v `pwd`/../data:/data -v `pwd`/../keys:/.gnupgp -v `pwd`/../../dist/cyphernode/logs:/cnlogs --network cyphernodenet  --name cn-pgp pgp-mosquitto:1.0 `id -u`:`id -g` ./gen-key.sh

generate_keys()
{
    local returncode
    echo gpg --list-keys Cypher Node | grep 'Cypher Node'
    returncode=$?

    if [ ${returncode} = "0" ]; then
        echo "CN PGP: CN key not found.  Creating Cyphernode key"
        gpg --batch --gen-key ./key-definition.txt
    else
        echo "CN PGP: CN key found.  Exiting"
    fi
}

generate_keys
