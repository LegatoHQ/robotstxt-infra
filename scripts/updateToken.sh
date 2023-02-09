source .env
source ./scripts/deployParams.sh

cast send $TOKEN_ADDRESS --rpc-url $MAINNET_RPC "setRobotTxt(address)()" $ROBOT_TXT_ADDRESS --private-key $DEPLOYER_PRIVATE_KEY