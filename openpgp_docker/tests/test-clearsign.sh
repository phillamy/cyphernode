#!/bin/sh

checkclearsign() {
  echo -en "\r\n\e[1;36mTesting Signature [clear sign]... " > /dev/console
  local response
  local returncode
  local body=`cat /tests/data/test-data.txt`
  local document

  echo "Body: ${body}"

  body=$(echo "${body}" | base64 -w 0)

  echo "Encoede Body: ${body}"

  response=$(mosquitto_rr -h broker -W 15 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"clearsign\",\"body\":\"${body}\"}")
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

  echo -e "\e[1;36mGPG clear sign rocks!" > /dev/console

  return 0
}

checkclearsign