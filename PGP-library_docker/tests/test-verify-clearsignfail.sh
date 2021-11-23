#!/bin/sh

checkverifyclearsignfail() {
  echo -en "\r\n\e[1;36mTesting Verify clearsign FAIL... " > /dev/console
  local response
  local returncode
  local pgp_signed=`cat tests/test-data-clear-signed-failed.txt`


  local body=$(echo "${pgp_signed}" | base64 -w 0)

  response=$(mosquitto_rr -h broker -W 15 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"verifyclearsign\",\"body\":\"${body}\"}")
  
  returncode=$?
  [ "${returncode}" -ne "0" ] && return 115

  response=$(echo ${response} | base64 -d)

  return_code=$(echo "${response}" | jq -r ".return_code")
  [ "${return_code}" -eq "0" ] && return 116

  echo "Response: ${response}"
  echo -e "\e[1;36mGPG Verify clearsign fail rocks!" > /dev/console

 
  return 0
}

checkverifyclearsignfail