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
echo "token:    $TOKEN_ADDRESS"
result=$(cast call $TOKEN_ADDRESS --rpc-url $MAINNET_RPC "robotTxt()(address)" 2>&1)
echo "Robots TXT:      $result"
# check equal to $ROBOT_TXT_ADDRESS
if [ "$result" = "$ROBOT_TXT_ADDRESS" ]; then
    echo -n -e "\u2705" 
    echo  " OK"
    echo "----------------"
    exit 0
else

    echo -n -e "\u274c"
    echo " ERROR: Owner is not Robot.txt"
    echo "----------------"
    echo expected: $ROBOT_TXT_ADDRESS
    echo "----------------"
    exit 1
fi  