// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {Configuration} from "./Configuration.sol";

library ConfigurationTest {
    bytes32 private constant SALT = hex"65617274686D696E64"; // earthmind
    string private constant SOURCE_CHAIN = Constants.LOCAL_L1_NETWORK;
    string private constant DESTINATION_CHAIN = Constants.LOCAL_L2_NETWORK;
    address private constant AXELAR_GATEWAY = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address private constant AXELAR_GAS_SERVICE = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;

    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues(SALT, SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}
