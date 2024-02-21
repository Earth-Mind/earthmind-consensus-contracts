set dotenv-load
set export

# @dev used to be able to do $L1 and differentiate parameters in the recipes
L1 := "L1"
L2 := "L2"

# @dev Be aware that NETWORK_ID is a parameters that will become an environment variable that thanks to set export.
# So the recipes require the NETWORK_ID in order to work properly.

# contract deployments
deploy_create2_deployer NETWORK_ID JSON_RPC_URL:
    forge script script/001_Deploy_Create2Deployer.s.sol:DeployCreate2DeployerScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_mock_gateway NETWORK_ID JSON_RPC_URL:
    forge script script/002_Deploy_Axelar_Mocks.s.sol:DeployAxelarMockScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_crosschain_setup NETWORK_ID JSON_RPC_URL:
    forge script script/003_Deploy_CrossChainSetup.s.sol:DeployCrossChainSetupScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_registry LAYER NETWORK_ID JSON_RPC_URL: 
    forge script script/004_Deploy_Registry_${LAYER}.s.sol:DeployRegistry${LAYER}Script --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_registry_l2 NETWORK_ID JSON_RPC_URL:
    forge script script/004_Deploy_Registry_L2.s.sol:DeployRegistryL2Script --rpc-url $CHAIN2_URL --chain-id $CHAIN2_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_consensus NETWORK_ID JSON_RPC_URL:
    forge script script/005_Deploy_Consensus.s.sol:DeployConsensusScript --rpc-url $JSON_RPC_URL --chain-id $NETWORK_ID --sender $SENDER --broadcast --ffi -vvvv

deploy_local_contracts:
    just deploy_create2_deployer $CHAIN1_ID $CHAIN1_URL # L1
    just deploy_create2_deployer $CHAIN2_ID $CHAIN2_URL # L2
    just deploy_mock_gateway $CHAIN1_ID $CHAIN1_URL # L1
    just deploy_mock_gateway $CHAIN2_ID $CHAIN2_URL # L2
    just deploy_crosschain_setup $CHAIN1_ID $CHAIN1_URL # L1
    just deploy_crosschain_setup $CHAIN2_ID $CHAIN2_URL # L2
    just deploy_registry $L1 $CHAIN1_ID $CHAIN1_URL # L1
    just deploy_registry $L2 $CHAIN2_ID $CHAIN2_URL # L2
    just deploy_consensus $CHAIN2_ID $CHAIN2_URL # L2

# orchestration and testing
coverage:
    forge coverage --report lcov
    genhtml lcov.info -o coverage --branch-coverage --ignore-errors category
