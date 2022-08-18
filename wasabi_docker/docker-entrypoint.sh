#!/bin/bash

waitforwasabi(){
  echo "[waitforwasabi] - Starting"

  local curl_output

  while true
  do
    curl_output=$(curl --config ${WASABI_RPC_CFG} -o /dev/null -w "%{http_code}" -s -d "{'jsonrpc':'2.0','id':'0','method':'getstatus', 'params': {} }" http://localhost:18099/);

    if [ "${curl_output}" = "200" ]; then
      echo "[waitforwasabi] - Wasabi is UP"
      break;
    else
      echo "[waitforwasabi] - Not ready - Sleeping 10 secs..."
      sleep 10
    fi
  done

  echo "[waitforwasabi] - Done"
}

createwallet(){
  local walletname=${1:-wasabi}
  local password=${2:-}

  echo "[createwallet] - Trying to createwallet [${walletname}] with password [${password}]"

  local curl_output=$(curl --config ${WASABI_RPC_CFG} -s -d "{'jsonrpc':'2.0','id':'0','method':'createwallet', 'params': {'walletName':'${walletname}','password':'${password}'} }" http://localhost:18099/)
  local result=$(echo $curl_output | jq -r '.result // "" ')

  if [ -n "${result}" ]; then
    echo "[createwallet] - Saving seed words in WALLETNAME-wallet-seed-words-YYYY-MM-DD-HH:MM:SS.txt"
    echo ${result} > /root/.walletwasabi/client/${walletname}-seed-words-`date +%F-%T`.txt
  else
    local error_code=$(echo $curl_output | jq -r '.error.code')

    if [ "${error_code}" = "-32603" ]; then
      # Wallet name is already taken
      echo "[createwallet] - OK - Skipping creation..."
      echo $curl_output | jq -r '.error.message'
    else
      echo "[createwallet] - Unexpected error [${curl_output}]"
      exit 1
    fi
  fi

  echo "[createwallet] - Done - createwallet [${walletname}] with password [${password}]"
}

selectwallet(){
  local walletname=${1:-wasabi}

  echo "[selectwallet] - Trying to selectwallet [${walletname}]"

  local curl_output=$(curl --config ${WASABI_RPC_CFG} -s -d "{'jsonrpc':'2.0','id':'0','method':'selectwallet', 'params': { 'walletName':'${walletname}' } }" http://localhost:18099/)
  local error=$(echo $curl_output | jq -r '.error // "" ')

  if [ -n "${error}" ]; then
    echo "[createwallet] - Unexpected error [${error}]"
    exit 2
  fi

  waitforwallet

  echo "[selectwallet] - Done - selectwallet [${walletname}]"
}

waitforwallet(){
  echo "[waitforwallet] - Starting"

  local curl_output
  local error

  while true
  do
    curl_output=$(curl --config ${WASABI_RPC_CFG} -s -d "{'jsonrpc':'2.0','id':'0','method':'getwalletinfo', 'params': {} }" http://localhost:18099/);
    error=$(echo $curl_output | jq -r '.error // "" ')

    if [ -z "${error}" ]; then
      echo "[waitforwallet] - Wallet is UP [${curl_output}]"
      break;
    else
      echo "[waitforwallet] - Not ready - Error: [${curl_output}] Sleeping 5 secs..."
      sleep 5
    fi
  done

  echo "[waitforwallet] - Done"
}

startcoinjoin(){
  local password=${1:-}

  echo "[startcoinjoin] - Trying to startcoinjoin with password [${password}]"

  local curl_output=$(curl --config ${WASABI_RPC_CFG} -s -d "{'jsonrpc':'2.0','id':'0','method':'startcoinjoin', 'params': { 'stopWhenAllMixed':'false', 'overridePlebStop':'true', 'password':'${password}'} }" http://localhost:18099/)
  local error=$(echo $curl_output | jq -r '.error // "" ')

  if [ -n "${error}" ]; then
    echo "[createwallet] - Unexpected error [${error}]"
    exit 2
  fi

  echo "[startcoinjoin] - Done - startcoinjoin with password [${password}]"
}

trim() {
	echo -e "$1" | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'
}

user=$( trim ${WASABI_RPC_USER} )
echo "user=${user}" > ${WASABI_RPC_CFG}

trap "pkill xvfb-run" TERM
/usr/bin/xvfb-run -e /output.txt -a dotnet /app/WalletWasabi.Fluent.Desktop.dll &

waitforwasabi
createwallet
selectwallet
startcoinjoin

#  Keep this file?
#rm ${WASABI_RPC_CFG}

wait

