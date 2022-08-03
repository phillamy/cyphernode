#!/bin/sh

# . /mine.sh

# This should be run in regtest

# docker run -it --rm --name cn-tests --network=cyphernodenet -v "$PWD/mine.sh:/mine.sh" -v "$PWD/tests.sh:/test-conjoin.sh" alpine /test-conjoin.sh

tests()
{
# wasabi_getnewaddress
  # (GET) http://proxy:8888/wasabi_getnewaddress

  echo "Testing wasabi_getnewaddress..."
  response=$(curl -s -H "Content-Type: application/json" -d "{\"label\":\"0\"}" proxy:8888/wasabi_getnewaddress)

  echo "response=${response}"

  local address0=$(echo ${response} | jq ".address")
  echo "address=${address0}"
  if [ -z "${address0}" ]; then
    exit 10
  fi
  echo "Tested wasabi_getnewaddress"

  echo "Testing wasabi_getnewaddress..."
  response=$(curl -s -H "Content-Type: application/json" -d "{\"label\":\"1\"}" proxy:8888/wasabi_getnewaddress)

  echo "response=${response}"

  local address1=$(echo ${response} | jq ".address")
  echo "address=${address1}"
  if [ -z "${address1}" ]; then
    exit 10
  fi
  echo "Tested wasabi_getnewaddress"

  response=$(curl -v -H "Content-Type: application/json" -d "{\"address\":${address0},\"amount\":0.20001}" proxy:8888/spend)
  echo "response=${response}"

  response=$(curl -v -H "Content-Type: application/json" -d "{\"address\":${address1},\"amount\":0.10001}" proxy:8888/spend)
  echo "response=${response}"
  echo
  echo "Please mine a block"
  echo

}

apk add curl jq

tests
