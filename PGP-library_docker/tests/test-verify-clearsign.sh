#!/bin/sh

checkverifyclearsign() {
  echo -en "\r\n\e[1;36mTesting Verify clearsign... " > /dev/console
  local response
  local returncode
  local pgp_signed=`cat tests/test-data-clear-signed.txt`


  local body=$(echo "${pgp_signed}" | base64 -w 0)

  echo "Body64: ${body}"

  response=$(mosquitto_rr -h broker -W 15 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"verifyclearsign\",\"body\":\"${body}\"}")
  
  returncode=$?
  [ "${returncode}" -ne "0" ] && return 115

  echo "Response: ${response}"
  echo -e "\e[1;36mGPG Verify clearsign rocks!" > /dev/console

  return 0
}

checkverifyclearsign