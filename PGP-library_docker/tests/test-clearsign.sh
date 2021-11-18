
#!/bin/sh

checkclearsign() {
  echo -en "\r\n\e[1;36mTesting Signature... " > /dev/console
  local response
  local returncode
  local body=$(echo "Hello world in GPG at `date -u +"%FT%H%MZ"`" | base64)

  response=$(mosquitto_rr -h broker -W 15 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"clearsign\",\"body\":\"${body}\"}")
  returncode=$?
  [ "${returncode}" -ne "0" ] && return 115

  echo "Response: ${response}"
  echo -e "\e[1;36mGPG Signature rocks!" > /dev/console

  return 0
}

checkclearsign