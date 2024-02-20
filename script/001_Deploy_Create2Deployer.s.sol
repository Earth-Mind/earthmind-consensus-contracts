// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {MockGateway} from "@contracts/mocks/MockGateway.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";

contract DeployCreate2DeployerScript is BaseScript {
    function run() public {
        console2.log("Deploying Create2Deployer contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = new Create2Deployer();
        console2.log("Create2Deployer Address");
        console2.logAddress(address(create2Deployer));

        // export the address of Create2Deployer
        // TODO
    }
}
