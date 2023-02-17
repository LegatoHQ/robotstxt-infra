#!/bin/bash
#if this fails to run, see https://stackoverflow.com/questions/21612980/running-shell-script-and-failing-with-bin-bashm-bad-interpreter-no-such-file-o
# sed -i -e 's/\r$//' ./scripts/*.sh
source .env.$1.sh

if [ -z "$1" ]
then
  echo "No network supplied"
  exit 1
fi
if [ -z "$ROBOT_TXT_ADDRESS" ]
then
  echo "No Robot txt address"
  exit 1
fi

echo
echo "----------------"
    
forge verify-contract --chain-id $CHAIN_ID \
    --num-of-optimizations 200 --watch  \
    --compiler-version v0.8.13          \
    --constructor-args $(cast abi-encode "constructor(address)" $TOKEN_ADDRESS) \
    $ROBOT_TXT_ADDRESS                  \
    ./src/RobotTxt.sol:RobotTxt         \
     $ETHERSCAN_API_KEY
