#!/bin/sh

. ./trace.sh

gpg_clearsign() {
  trace "Entering gpg_clearsign()..."

  local body=${1} #base64 encoded

  local returncode
  local response

  response=$(mosquitto_rr -h broker -W 21 -t gpg -e "response/$$" -m "{\"response-topic\":\"response/$$\",\"cmd\":\"clearsign\",\"body\":\"${body}\"}")
  returncode=$?

  trace_rc ${returncode}

  trace "[gpg_clearsign] msg=${response}"
  echo "${response}"

  [ "${returncode}" -ne "0" ] && return 1

  trace "[gpg_clearsign] response=${response}"

  return_code=$(echo "${response}" | jq -r '.return_code')
  [ "${return_code}" -ne "0" ] && return 2

  return 0
}

gpg_verify_clearsign() {
  trace "Entering gpg_verify_clearsign()..."

  local body=${1} #base64 encoded

  local returncode
  local response
  
  msg="{\"response-topic\":\"response/$$\",\"cmd\":\"verifyclearsign\",\"body\":\"${body}\"}"

  trace "[gpg_clearsign] mosquitto_rr -h broker -W 21 -t gpg -e \"response/$$\" -m ${msg}"
  response=$(mosquitto_rr -h broker -W 21 -t gpg -e "response/$$" -m ${msg})
  returncode=$?

  trace_rc ${returncode}
  trace "[gpg_verify_clearsign] response=${response}"

  echo "${response}"

  [ "${returncode}" -ne "0" ] && return 3

  returncode=$(echo "${response}" | jq -r '.return_code')

  [ ${returncode} -ne "0" ] && return 4

  return 0
}

gpg_detachsign() {
  trace "Entering gpg_detachsign()..."

  local body=${1} #base64 encoded

  local returncode
  local response
  
  msg="{\"response-topic\":\"response/$$\",\"cmd\":\"detachsign\",\"body\":\"${body}\"}"

  trace "[gpg_clearsign] mosquitto_rr -h broker -W 21 -t gpg -e \"response/$$\" -m ${msg}"
  response=$(mosquitto_rr -h broker -W 21 -t gpg -e "response/$$" -m ${msg})
  returncode=$?

  trace_rc ${returncode}
  trace "[gpg_detachsign] response=${response}"

  echo "${response}"

  [ "${returncode}" -ne "0" ] && return 5

  returncode=$(echo "${response}" | jq -r '.return_code')

  [ ${returncode} -ne "0" ] && return 6

  return 0
}

gpg_verify_detachsign() {
  trace "Entering gpg_verify_detachsign()..."

  local body=${1} #base64 encoded
  local original_message=${2} #base64 encoded

  local returncode
  local response
  
  msg="{\"response-topic\":\"response/$$\",\"cmd\":\"verifydetachsign\",\"body\":\"${body}\",\"original_message\":\"${original_message}\"}"

  trace "[gpg_verify_detachsign] mosquitto_rr -h broker -W 21 -t gpg -e \"response/$$\" -m ${msg}"
  response=$(mosquitto_rr -h broker -W 21 -t gpg -e "response/$$" -m "${msg}")
  returncode=$?

  trace_rc ${returncode}
  trace "[gpg_verify_detachsign] response=${response}"

  echo "${response}"

  [ "${returncode}" -ne "0" ] && return 7

  returncode=$(echo "${response}" | jq -r '.return_code')

  [ ${returncode} -ne "0" ] && return 8

  return 0
}