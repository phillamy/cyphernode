#!/bin/sh

# Tests the gpg_clearsign (in gpg.sh) function by calling it directly (Mosquitto) - not going through the proxy.
#
# Run inside this container:
#   docker run -v `pwd`:/app --rm -it --network cyphernodenet eclipse-mosquitto:1.6-openssl sh
#
# Also make sure this container is running PGP-library_docker
#   docker build -t pgp-mosquitto:1.0 .
#   docker run --rm -v `pwd`/data/:/data -v `pwd`/keys:/.gnupgp -v `pwd`/../dist/cyphernode/logs:/cnlogs --network cyphernodenet --name cn-pgp pgp-mosquitto:1.0 `id -u`:`id -g` ./startgpg.sh
#
cd ../script
. ./gpg.sh

test_gpg_clearsign()
{
    local response
    
    response=$(gpg_clearsign "${1}")
    returncode=$?

    [ "${returncode}" -ne "0" ] && return 100

    echo "${response}"

    return 0
}

test_gpg_detachsign()
{
    local response

    response=$(gpg_detachsign "${1}")
    returncode=$?

    [ "${returncode}" -ne "0" ] && return 200

    echo "${response}"

    return 0
}

test_gpg_verify_clearsign()
{
    local response
    echo "Calling gpg_verify_clearsign..."

    response=$(gpg_verify_clearsign "${1}")
    returncode=$?

    [ "${returncode}" -ne "0" ] && return 300

    echo "${response}"
}

test_gpg_verify_detachsign()
{
    local response
    echo "Calling gpg_verify_detachsign..."

    response=$(gpg_verify_detachsign "${1}" "${2}")
    returncode=$?

    [ "${returncode}" -ne "0" ] && return 400

    echo "${response}"
}

clear_sign_verify()
{
    local response
    local original_message="Unit testing GPG detach at `date -u +"%FT%H%MZ"`"
    local b64_msg=$(echo ${original_message} | base64 -w 0)
    local pgp_message

    echo "------------------------ Clear sign ----------------------------------------------"

    response=$(test_gpg_clearsign "${b64_msg}")
    echo "${response}"

    echo "------------------------ Verify clear sign ----------------------------------------------"

    pgp_message=$(echo "${response}" | jq '.body')
    response=$(test_gpg_verify_clearsign "${pgp_message}")
    echo "${response}"
}

detach_sign_verify()
{
    local response
    local original_message="Unit testing GPG detach at `date -u +"%FT%H%MZ"`"
    local signature
    local b64_msg=$(echo ${original_message} | base64 -w 0)

    echo "------------------------ Detach sign ----------------------------------------------"

    signature=$(test_gpg_detachsign "${b64_msg}")
    signature=$(echo "${signature}" | jq '.body')

    echo "------------------------ Verify detach sign ----------------------------------------------"
    echo "Original: >${b64_msg}<"
    echo "Signature: >${signature}<"
    response=$(test_gpg_verify_detachsign "${signature}" "${original_message}")
    echo $?

    echo "${response}"
}
  apk add jq

  clear_sign_verify
  detach_sign_verify


