source .env
source ./scripts/deployParams.sh

forge create --rpc-url $MAINNET_RPC \
    --private-key $DEPLOYER_PRIVATE_KEY \
    --constructor-args $TOKEN_ADDRESS \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verify \
    src/RobotTxt.sol:RobotTxt
