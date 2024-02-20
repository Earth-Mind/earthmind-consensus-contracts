set dotenv-load

deploy_create2_deployer_l1:
    forge script script/001_Deploy_Create2Deployer.s.sol:DeployCreate2DeployerScript --rpc-url $CHAIN1_URL --broadcast --ffi -vvvv

deploy_create2_deployer_l2:
    forge script script/001_Deploy_Create2Deployer.s.sol:DeployCreate2DeployerScript --rpc-url $CHAIN2_URL --broadcast --ffi -vvvv

deploy_mock_gateway_l1:
    forge script script/002_Deploy_Axelar_Mocks.s.sol:DeployAxelarMockScript --rpc-url $CHAIN1_URL --broadcast --ffi -vvvv

deploy_mock_gateway_l2:
    forge script script/002_Deploy_Axelar_Mocks.s.sol:DeployAxelarMockScript --rpc-url $CHAIN2_URL --broadcast --ffi -vvvv

deploy_core_contracts:
    forge script script/003_Deploy_Core.s.sol:DeployCoreScript --rpc-url $CHAIN2_URL --broadcast -vvvv

deploy_local_contracts:
    just deploy_create2_deployer_l1
    just deploy_create2_deployer_l2
    just deploy_mock_gateway_l1
    just deploy_mock_gateway_l2