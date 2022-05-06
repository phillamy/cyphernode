#!/bin/sh

BITCOIN_CLI='bitcoin-cli'

while [ -z "`bitcoin-cli echo`"  ]; do echo "CYPHERNODE[createWallet]: bitcoind not ready" ; sleep 10 ; done
echo "CYPHERNODE[createWallet]: bitcoind is ready"

# Check for the basic wallets.  If not present, create.
BASIC_WALLETS='"watching01.dat" "xpubwatching01.dat" "spending01.dat"'

CURRENT_WALLETS=`$BITCOIN_CLI listwallets`

for wallet in $BASIC_WALLETS
do
    echo "CYPHERNODE[createWallet]: Checking wallet [$wallet]"
    echo "$CURRENT_WALLETS" | grep -F $wallet > /dev/null 2>&1

    if [ "$?" -ne "0" ]; then
       walletNameNoQuote=`echo $wallet | tr -d '"'`
       $BITCOIN_CLI createwallet ${walletNameNoQuote} && echo "CYPHERNODE[createWallet]: new wallet created : [$walletNameNoQuote]"
    else
       echo "CYPHERNODE[createWallet]: Wallet [$wallet] found"
    fi
done

<% if( net === 'regtest' ) { %>
BLOCKS_TO_MINE_MAKE_SPENDABLE=100
WALLET=spending01.dat
MIN_BALANCE=1.00000000
balance=`bitcoin-cli -rpcwallet=$WALLET getbalance`
echo "CYPHERNODE[createWallet]: Current balance [$balance] - Min balance is [$MIN_BALANCE]"

while [ `expr $balance \< $MIN_BALANCE` -eq 1 ]; do
  echo "CYPHERNODE[createWallet]: Balance [$balance] is less than [$MIN_BALANCE] - mining 1 block"
  bitcoin-cli -rpcwallet=$WALLET -generate 1
  echo "CYPHERNODE[createWallet]: Done mining 1 block"
  balance=`bitcoin-cli -rpcwallet=$WALLET getbalance`
  echo "CYPHERNODE[createWallet]: New balance [$balance]"
done
<% } %>