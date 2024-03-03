// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {Configuration} from "./Configuration.sol";

import {Vm} from "forge-std/Vm.sol";

library ConfigurationL1Local {
    using DeploymentUtils for Vm;

    string private constant SOURCE_CHAIN = Constants.LOCAL_L1_NETWORK;
    string private constant DESTINATION_CHAIN = Constants.LOCAL_L2_NETWORK;

    function getConfig(Vm vm) external view returns (Configuration.ConfigValues memory) {
        address AXELAR_GATEWAY = vm.loadDeploymentAddress(Constants.MOCK_GATEWAY);
        address AXELAR_GAS_SERVICE = vm.loadDeploymentAddress(Constants.MOCK_GAS_RECEIVER);

        return Configuration.ConfigValues(SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}

library ConfigurationL2Local {
    using DeploymentUtils for Vm;

    string private constant SOURCE_CHAIN = Constants.LOCAL_L2_NETWORK;
    string private constant DESTINATION_CHAIN = Constants.LOCAL_L1_NETWORK;

    function getConfig(Vm vm) external view returns (Configuration.ConfigValues memory) {
        address AXELAR_GATEWAY = vm.loadDeploymentAddress(Constants.MOCK_GATEWAY);
        address AXELAR_GAS_SERVICE = vm.loadDeploymentAddress(Constants.MOCK_GAS_RECEIVER);

        return Configuration.ConfigValues(SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}
