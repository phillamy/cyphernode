#!/bin/sh

BITCOIN_CLI='bitcoin-cli'

<% if( net === 'regtest' ) { %>
BITCOIN_CLI="$BITCOIN_CLI -regtest"
<% } %>

sleep 2

<% if( net === 'regtest' ) { %>
while ! ${BITCOIN_CLI} echo &> /dev/null; do echo "CYPHERNODE[createwallet]: bitcoind not ready"; sleep 10; done
<% } else { %>
while [ ! -f "/container_monitor/bitcoin_ready" ]; do echo "CYPHERNODE[createWallet]: bitcoind not ready" ; sleep 10 ; done
<% } %>

echo "CYPHERNODE[createWallet]: bitcoind is ready"

# Check for the basic wallets.  If not present, create.
BASIC_WALLETS='"watching01.dat" "xpubwatching01.dat" "spending01.dat"'

CURRENT_WALLETS=`$BITCOIN_CLI listwallets`

for wallet in $BASIC_WALLETS
do
    echo "CYPHERNODE[createwallet]: Checking wallet [$wallet]"
    echo "$CURRENT_WALLETS" | grep -F $wallet > /dev/null 2>&1

    if [ "$?" -ne "0" ]; then
       walletNameNoQuote=`echo $wallet | tr -d '"'`
       $BITCOIN_CLI createwallet ${walletNameNoQuote} && echo "CYPHERNODE[createwallet]: new wallet created : [$walletNameNoQuote]"
    else
       echo "CYPHERNODE[createwallet]: Wallet [$wallet] found"
    fi
done

<% if( net === 'regtest' ) { %>
# Mining blocks in regtest to have at least 101 blocks
MINBLOCK=101
WALLET=watching01.dat

blockcount=`$BITCOIN_CLI getblockcount`                            
blocktomine=`expr $MINBLOCK - $blockcount`
[ $blocktomine -gt 0 ] && echo "CYPHERNODE[regtest-mine]: About to mine [$blocktomine] new block(s)" && $BITCOIN_CLI -rpcwallet=$WALLET generatetoaddress $blocktomine $($BITCOIN_CLI -rpcwallet=$WALLET getnewaddress) > /dev/null 2>&1

echo "CYPHERNODE[regtest-mine]: Done mining [$blocktomine] new block(s)"
<% } %>
