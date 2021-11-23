#!/bin/sh

checkverifycdetachsign() {
  echo -en "\r\n\e[1;36mTesting Verify detachsign... " > /dev/console
  local response
  local returncode
  local pgp_signed=`cat tests/test-data-detach-signed.txt`
  local original_message=`cat tests/test-data-detach-signed-input.txt`


  local body=$(echo "${pgp_signed}" | base64 -w 0)
  local original_message=$(echo "${original_message}" | base64 -w 0)
  
  response=$(mosquitto_rr -h broker -W 15 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"verifydetachsign\",\"body\":\"${body}\",\"original_message\":\"${original_message}\"}")
  
  returncode=$?
  [ "${returncode}" -ne "0" ] && return 115

  response=$(echo ${response} | base64 -d)

  echo "Response: ${response}"

  return_code=$(echo "${response}" | jq -r ".return_code")
  [ "${return_code}" -ne "0" ] && return 116

  echo "Response: ${response}"
  echo -e "\e[1;36mGPG Verify detachsign fail rocks!" > /dev/console


  return 0
}

checkverifycdetachsign