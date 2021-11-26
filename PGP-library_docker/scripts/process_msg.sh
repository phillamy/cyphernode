#!/bin/sh

. ./trace.sh

# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Esoteric-Options.html#GPG-Esoteric-Options
# --passphrase-file file --pinentry-mode loopback
# Read the passphrase from file file. Only the first line will be read from file file. This can only be used if only one passphrase is supplied. Obviously, a passphrase stored in a file is of questionable security if other users can read this file. Don’t use this option if you can avoid it.
#
# Note that since Version 2.0 this passphrase is only used if the option --batch has also been given. Since Version 2.1 the --pinentry-mode also needs to be set to loopback.
#

process_clearsign(){
  trace "Entering process_clearsign()..."

  local msg=${1}
  local body
  local response
  local returncode
  local b64response
  local message

  trace "[process_clearsign] msg=${msg}"
  body=$(echo ${msg} | jq -e ".body" | base64 -d)
  
  trace "[process_clearsign] body=${body}"

  response=$(echo "${body}" | gpg --clear-sign 2>&1 )
  returncode=$?

  trace_rc ${returncode}

  trace "[process_clearsign] gpg response=${response}"

  b64response=$(echo "${response}" | base64 -w 0)

  message="{\"return_code\":\"${returncode}\",\"body\":\"${b64response}\"}"

  echo "${message}"

  return ${returncode}
}

process_verifyclearsign(){
  trace "Entering process_verifyclearsign()..."

  local msg=${1}
  local body
  local response
  local returncode
  local b64response
  local message

  trace "[process_verifyclearsign] msg=${msg}"
  body=$(echo "${msg}" | jq -e ".body" | base64 -d)
  
  trace "[process_verifyclearsign] body=${body}"

  response=$(echo "${body}" | gpg --verify 2>&1)

  #Grep 'gpg: Good signature from ' because de rc is 0 most of the time
  echo ${response} | grep -q 'gpg: Good signature from '
  returncode=$?

  trace "[process_verifyclearsign] gpg response=${response}"

  trace_rc ${returncode}

  b64response=$(echo "${response}" | base64 -w 0)

  message="{\"return_code\":\"${returncode}\",\"body\":\"${b64response}\"}"
  echo "${message}"

  return ${returncode}
}

process_detachsign(){
  trace "Entering process_detachsign()..."

  local msg=${1}
  local body
  local response
  local returncode
  local b64response
  local message

  trace "[process_detachsign] msg=${msg}"
  body=$(echo "${msg}" | jq -e ".body" | base64 -d)
  
  trace "[process_detachsign] body=${body}"

  response=$(echo "${body}" | gpg --detach-sig --armor 2>&1)
  returncode=$?

  trace "[process_detachsign] gpg response=${response}"

  trace_rc ${returncode}

  b64response=$(echo "${response}" | base64 -w 0)

  message="{\"return_code\":\"${returncode}\",\"body\":\"${b64response}\"}"

  echo "${message}"

  return ${returncode}
}

#
# Body contains signature
#
process_verifydetachsign(){
  trace "Entering process_verifydetachsign()..."

  local msg=${1}
  local body
  local response
  local returncode
  local original_message
  local temp_FILENAME=$(mktemp)
  local b64response
  local message

  trace "[process_verifydetachsign] msg=${msg}"
  body=$(echo "${msg}" | jq -e ".body" | base64 -d)
  original_message=$(echo ${msg} | jq -e ".original_message" | base64 -d)

  trace "[process_verifydetachsign] body=${body}"
  trace "[process_verifydetachsign] message=${original_message}"

  echo "${original_message}" > "${temp_FILENAME}"

  response=$(echo "${body}" | gpg --armor --verify - ${temp_FILENAME} 2>&1)
  rm -f ${temp_FILENAME}

  #Grep 'gpg: Good signature from ' because de rc is 0 most of the time
  echo ${response} | grep -q 'gpg: Good signature from '
  returncode=$?

  trace "[process_verifydetachsign] gpg response=${response}"

  trace_rc ${returncode}

  b64response=$(echo "${response}" | base64 -w 0)

  message="{\"return_code\":\"${returncode}\",\"body\":\"${b64response}\"}"

  echo "${message}"

  return ${returncode}
}