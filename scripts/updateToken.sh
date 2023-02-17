#!/bin/bash
#if this fails to run, see https://stackoverflow.com/questions/21612980/running-shell-script-and-failing-with-bin-bashm-bad-interpreter-no-such-file-o
# sed -i -e 's/\r$//' ./scripts/*.sh
source .env.$1.sh

cast send $TOKEN_ADDRESS --rpc-url $MAINNET_RPC "setRobotTxt(address)()" $ROBOT_TXT_ADDRESS --private-key $DEPLOYER_PRIVATE_KEY
./scripts/check.sh $1