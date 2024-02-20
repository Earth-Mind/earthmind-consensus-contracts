// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Configuration} from "@config/Configuration.sol";

contract BaseScript is Script {
    Configuration.ConfigValues internal config;
    address internal deployer;

    constructor() {
        config = _loadConfig();
        deployer = _loadDeployerInfo();
    }

    function _loadConfig() private view returns (Configuration.ConfigValues memory) {
        uint256 networkId = vm.envUint("NETWORK_ID");

        return Configuration.getConfiguration(networkId);
    }

    function _loadDeployerInfo() private returns (address) {
        uint256 deployerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC"), 0);

        return vm.rememberKey(deployerPrivateKey);
    }
}
