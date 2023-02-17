#!/bin/bash
#if this fails to run, see https://stackoverflow.com/questions/21612980/running-shell-script-and-failing-with-bin-bashm-bad-interpreter-no-such-file-o
# sed -i -e 's/\r$//' ./scripts/*.sh
source .env.$1.sh

if [ -z "$1" ]
then
  echo "No network supplied"
  exit 1
fi

echo
echo "----------------"
echo checking on $1
echo "calling    $TOKEN_ADDRESS"
result=$(cast call $ROBOT_TXT_ADDRESS --rpc-url $MAINNET_RPC "totalLicenseCount()(uint256)" 2>&1)
echo "got:      $result"