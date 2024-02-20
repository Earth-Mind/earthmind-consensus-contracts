set dotenv-load
set export

# contract deployments
deploy_create2_deployer_l1 NETWORK_ID JSON_RPC_URL:
    echo "Deploying Create2Deployer to $NETWORK_ID"
    echo "Using RPC URL: $JSON_RPC_URL"
    forge script script/001_Deploy_Create2Deployer.s.sol:DeployCreate2DeployerScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --broadcast --ffi -vvvv

deploy_create2_deployer_l2 NETWORK_ID JSON_RPC_URL:
    forge script script/001_Deploy_Create2Deployer.s.sol:DeployCreate2DeployerScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --broadcast --ffi -vvvv

deploy_mock_gateway_l1 NETWORK_ID JSON_RPC_URL:
    forge script script/002_Deploy_Axelar_Mocks.s.sol:DeployAxelarMockScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --broadcast --ffi -vvvv

deploy_mock_gateway_l2 NETWORK_ID JSON_RPC_URL:
    forge script script/002_Deploy_Axelar_Mocks.s.sol:DeployAxelarMockScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --broadcast --ffi -vvvv

deploy_core_contracts NETWORK_ID JSON_RPC_URL:
    forge script script/003_Deploy_Core.s.sol:DeployCoreScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --broadcast -vvvv

deploy_local_contracts:
    just deploy_create2_deployer_l1 $CHAIN1_ID $CHAIN1_URL
    just deploy_create2_deployer_l2 $CHAIN2_ID $CHAIN2_URL
    just deploy_mock_gateway_l1 $CHAIN1_ID $CHAIN1_URL
    just deploy_mock_gateway_l2 $CHAIN2_ID $CHAIN2_URL

# orchestration and testing
coverage:
    forge coverage --report lcov
    genhtml lcov.info -o coverage --branch-coverage --ignore-errors category
