set dotenv-load

deploy_create2_deployer:
    forge script script/001_Deploy_Create2Deployer.s.sol:DeployCreate2DeployerScript --rpc-url $CHAIN1_URL
