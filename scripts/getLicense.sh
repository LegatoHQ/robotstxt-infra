#!/bin/bash
#if this fails to run, see https://stackoverflow.com/questions/21612980/running-shell-script-and-failing-with-bin-bashm-bad-interpreter-no-such-file-o
# sed -i -e 's/\r$//' ./scripts/*.sh
source .env
source ./scripts/deployParams.sh

# cast send $ROBOT_TXT_ADDRESS --rpc-url $MAINNET_RPC "licenseOf(address)()" $ADDRESS 
export LICENSE=somelicneseuri
export INFO=someinfo
cast send $ROBOT_TXT_ADDRESS "setDefaultLicense(address,string,string)()" $WRITER_ADDRESS $LICENSE $INFO --private-key $WRITER_PRIVATE_KEY --rpc-url $MAINNET_RPC -- --verbose
echo "License set to $LICENSE"
# cast call $ROBOT_TXT_ADDRESS --rpc-url $MAINNET_RPC "licenseOf(address)(string,string)" $ADDRESS 
