// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {MockGateway} from "@contracts/mocks/MockGateway.sol";

import {Configuration} from "@config/Configuration.sol";

import {console2} from "forge-std/Script.sol";
import {BaseScript} from "./000_BaseScript.s.sol";

contract DeployCreate2DeployerScript is BaseScript {
    function run() public {
        console2.log("Deploying Create2Deployer contract");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = new Create2Deployer();

        // calculate the address of mock gateway
        bytes memory mockGatewayCreationCode = abi.encodePacked(type(MockGateway).creationCode);

        address mockGatewayComputedAddress =
            create2Deployer.computeAddress(config.salt, keccak256(mockGatewayCreationCode));

        console2.logAddress(mockGatewayComputedAddress);
    }
}
