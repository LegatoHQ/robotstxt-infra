#!/bin/bash
#if this fails to run, see https://stackoverflow.com/questions/21612980/running-shell-script-and-failing-with-bin-bashm-bad-interpreter-no-such-file-o
# run it with ./scripts/deployToken.sh , not with "sh scripts/deployToken.sh"
# or https://stackoverflow.com/questions/14219092/bash-script-bin-bashm-bad-interpreter-no-such-file-or-directory
# or https://stackoverflow.com/questions/10376206/what-is-the-preferred-bash-shebang

source .env.$1.sh

forge create --rpc-url $MAINNET_RPC \
    --private-key $DEPLOYER_PRIVATE_KEY \
    --constructor-args $TOKEN_NAME $TOKEN_SYMBOL \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify \
    src/token/Robot.sol:Robot