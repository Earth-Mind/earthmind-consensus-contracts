// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {Configuration} from "./Configuration.sol";

library ConfigurationTest {
    string private constant SOURCE_CHAIN = Constants.LOCAL_L1_NETWORK;
    string private constant DESTINATION_CHAIN = Constants.LOCAL_L2_NETWORK;
    address private constant AXELAR_GATEWAY = address(0); // @dev Since these contracts are deploying in the unit test
    address private constant AXELAR_GAS_SERVICE = address(0); // there is not need to declare any addresses

    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues(
            Constants.SALT, SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE
        );
    }
}
