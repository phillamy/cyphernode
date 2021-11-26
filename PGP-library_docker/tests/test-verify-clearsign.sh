#!/bin/sh

checkverifyclearsign() {
  echo -en "\r\n\e[1;36mTesting Verify clearsign... " > /dev/console
  local response
  local returncode
  local pgp_signed=`cat /tests/data/test-data-clear-signed.txt`
  local document
  
  echo "Input: ${pgp_signed}"

  local body=$(echo "${pgp_signed}" | base64 -w 0)
  
  echo "Body: ${body}"

  response=$(mosquitto_rr -h broker -W 15 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"verifyclearsign\",\"body\":\"${body}\"}")
  
  returncode=$?
  [ "${returncode}" -ne "0" ] && return 115

  echo "Response: ${response}"

  returncode=$(echo "${response}" | jq -r '.return_code')
  echo "Returncode: ${returncode}"

  [ ${returncode} -ne "0" ] && return 116

  body=$(echo "${response}" | jq -r '.body')
  echo "Body: ${body}"
  document=$(echo "${body}" | base64 -d)

  echo "DecodedBody: >${document}<"

  echo -e "\e[1;36mGPG Verify clearsign rocks!" > /dev/console

  return 0
}

checkverifyclearsign