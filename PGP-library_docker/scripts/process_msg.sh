
#!/bin/sh

. ./trace.sh

process_msg(){
  trace "Entering process_msg()..."

  local msg=${1}
  local body
  local response
  local returncode

  trace "[process_msg] msg=${msg}"
  body=$(echo ${msg} | jq -e ".body" | base64 -d)
  
  trace "[process_msg] body=${body}"

  response=$(echo \"${body}\" | gpg --clear-sign)

  trace "[process_msg] gpg response=${response}"

  returncode=$?
  trace_rc ${returncode}

  echo "${response}"

  return ${returncode}
}
