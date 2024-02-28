// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Configuration} from "@config/Configuration.sol";
import {DeployerUtils} from "@utils/DeployerUtils.sol";

import {Script, console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract BaseScript is Script {
    using DeployerUtils for Vm;
    using Configuration for Vm;

    Configuration.ConfigValues internal config;
    address internal deployer;

    struct Deployment {
        string name;
        address addr;
    }

    string internal deploymentsPath;
    string internal folderPath;

    constructor() {
        string memory networkId = vm.envString("NETWORK_ID");
        config = vm.getConfiguration(networkId);
        deployer = vm.loadDeployerAddress();

        // setup paths
        string memory root = vm.projectRoot();
        deploymentsPath = string.concat(root, "/deployments/");

        folderPath = string.concat(deploymentsPath, networkId);
    }
}
