set dotenv-load
set export

# contract deployments
deploy_create2_deployer NETWORK_ID JSON_RPC_URL:
    forge script script/001_Deploy_Create2Deployer.s.sol:DeployCreate2DeployerScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_mock_gateway NETWORK_ID JSON_RPC_URL:
    forge script script/002_Deploy_Axelar_Mocks.s.sol:DeployAxelarMockScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_crosschain_setup NETWORK_ID JSON_RPC_URL:
    forge script script/003_Deploy_CrossChainSetup.s.sol:DeployCrossChainSetupScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_local_contracts:
    just deploy_create2_deployer $CHAIN1_ID $CHAIN1_URL # L1
    just deploy_create2_deployer $CHAIN2_ID $CHAIN2_URL # L2
    just deploy_mock_gateway $CHAIN1_ID $CHAIN1_URL # L1
    just deploy_mock_gateway $CHAIN2_ID $CHAIN2_URL # L2
    just deploy_crosschain_setup $CHAIN1_ID $CHAIN1_URL # L1
    just deploy_crosschain_setup $CHAIN2_ID $CHAIN2_URL # L2

# orchestration and testing
coverage:
    forge coverage --report lcov
    genhtml lcov.info -o coverage --branch-coverage --ignore-errors category
