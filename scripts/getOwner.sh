#!/bin/bash
#if this fails to run, see https://stackoverflow.com/questions/21612980/running-shell-script-and-failing-with-bin-bashm-bad-interpreter-no-such-file-o
# sed -i -e 's/\r$//' ./scripts/*.sh
source .env.$1.sh

# cast send $ROBOT_TXT_ADDRESS --rpc-url $MAINNET_RPC "licenseOf(address)()" $ADDRESS 
cast call $2 --rpc-url $MAINNET_RPC "owner()(address)" 
