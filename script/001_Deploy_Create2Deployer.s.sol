// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {Constants} from "@constants/Constants.sol";
import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployCreate2DeployerScript is BaseScript {
    using DeploymentUtils for Vm;

    bool private SKIP_CONFIGURATION = true;

    function run() public {
        console2.log("Deploying Create2Deployer contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = new Create2Deployer();
        console2.log("Create2Deployer Address");
        console2.logAddress(address(create2Deployer));

        vm.saveDeploymentAddress(Constants.CREATE2_DEPLOYER, address(create2Deployer));
    }

    function _skipLoadConfig() internal view override returns (bool) {
        return SKIP_CONFIGURATION;
    }
}
