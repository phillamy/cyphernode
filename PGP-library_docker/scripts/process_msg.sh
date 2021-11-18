
#!/bin/sh

. ./trace.sh

# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Esoteric-Options.html#GPG-Esoteric-Options
# --passphrase-file file
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

  trace "[process_clearsign] msg=${msg}"
  body=$(echo ${msg} | jq -e ".body" | base64 -d)
  
  trace "[process_clearsign] body=${body}"

  response=$(echo \"${body}\" | gpg --batch --pinentry-mode loopback --passphrase-file ./data/passphrase.txt --clear-sign  2>&1)
  returncode=$?

  trace "[process_clearsign] gpg response=${response}"

  trace_rc ${returncode}

  echo "${response}"

  return ${returncode}
}

process_verifyclearsign(){
  trace "Entering process_verifyclearsign()..."

  local msg=${1}
  local body
  local response
  local returncode

  trace "[process_verifyclearsign] msg=${msg}"
  body=$(echo ${msg} | jq -e ".body" | base64 -d)
  
  trace "[process_verifyclearsign] body=${body}"

  response=$(echo "${body}" | gpg --verify 2>&1)
  returncode=$?

  trace "[process_verifyclearsign] gpg response=${response}"

  trace_rc ${returncode}

  echo "${response}"

  return ${returncode}
}