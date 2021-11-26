#!/bin/sh

# Tests the gpg_clearsign (in gpg.sh) function by calling it directly - not going through the proxy.

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
    
    echo "------------------------ Clear sign ----------------------------------------------"

    response=$(test_gpg_clearsign "Unit testing GPG clear at `date -u +"%FT%H%MZ"`")
    echo "${response}"

    echo "------------------------ Verify clear sign ----------------------------------------------"

    response=$(test_gpg_verify_clearsign "${response}")
    echo "${response}"
}

detach_sign_verify()
{
    local response
    local original_message="Unit testing GPG detach at `date -u +"%FT%H%MZ"`"
    local signature

    echo "------------------------ Detach sign ----------------------------------------------"

    signature=$(test_gpg_detachsign "${original_message}")
    echo "${signature}"

    echo "------------------------ Verify detach sign ----------------------------------------------"
    echo "Original: >${original_message}<"
    echo "Signature: >${signature}<"
    response=$(test_gpg_verify_detachsign "${signature}" "${original_message}")
    echo $?

    echo "${response}"
}

  clear_sign_verify
  detach_sign_verify


