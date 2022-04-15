#!/bin/sh

. ./trace.sh

sql() {
  trace "Entering sql()..."

  local select_id=${2}
  local response
  local inserted_id

  trace "[sql] psql -qAtX -h postgres -U cyphernode -c \"${1}\""
  response=$(psql -qAtX -h postgres -U cyphernode -c "${1}")
  returncode=$?
  trace_rc ${returncode}

  if [ -n "${select_id}" ]; then
    if [ "${returncode}" -eq "0" ]; then
      inserted_id=$(echo "${response}" | cut -d ' ' -f1)
    else
      trace "[sql] psql -qAtX -h postgres -U cyphernode -c \"${select_id}\""
      inserted_id=$(psql -qAtX -h postgres -U cyphernode -c "${select_id}")
      returncode=$?
      trace_rc ${returncode}
    fi
    echo -n "${inserted_id}"
  else
    echo -n "${response}"
  fi

  return ${returncode}
}
