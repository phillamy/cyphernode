#!/bin/sh

checkdetachsign() {
  echo -en "\r\n\e[1;36mTesting Signature [detach sign]... " > /dev/console
  local response
  local returncode
  local body=$(echo "Hello world in GPG at `date -u +"%FT%H%MZ"`" | base64)

  response=$(mosquitto_rr -h broker -W 15 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"detachsign\",\"body\":\"${body}\"}")
  returncode=$?
  [ "${returncode}" -ne "0" ] && return 115

  return_code=$(echo "${response}" | jq -r ".return_code")
  [ "${return_code}" -ne "0" ] && return 116

  echo "Response: ${response}"
  echo -e "\e[1;36mGPG detach sign rocks!" > /dev/console

  return 0
}

checkdetachsign
