// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {MockGateway} from "@contracts/mocks/MockGateway.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";

contract DeployAxelarMockScript is BaseScript {
    function run() public {
        console2.log("Deploying AxelarMockGateway contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(_loadCreate2DeployerAddress());

        // calculate the address of mock gateway
        bytes memory mockGatewayCreationCode = abi.encodePacked(type(MockGateway).creationCode);

        address mockGatewayComputedAddress =
            create2Deployer.computeAddress(config.salt, keccak256(mockGatewayCreationCode));

        console2.log("Computed address of MockGateway");
        console2.logAddress(mockGatewayComputedAddress);

        // deploy the mock gateway contract
        address deployedAddressOfMockGateway = create2Deployer.deploy(0, config.salt, mockGatewayCreationCode);

        assert(deployedAddressOfMockGateway == mockGatewayComputedAddress);

        _exportDeployment("MockGateway", deployedAddressOfMockGateway);
    }
}
