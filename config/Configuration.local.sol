// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Configuration} from "./Configuration.sol";

library ConfigurationLocal {
    bytes32 private constant SALT = hex"65617274686D696E64"; // earthmind
    string private constant SOURCE_CHAIN = "5"; // Goerli for testing
    string private constant DESTINATION_CHAIN = "1313161555"; // Aurora testnet for testing
    address private constant AXELAR_GATEWAY = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address private constant AXELAR_GAS_SERVICE = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;

    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues(SALT, SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}
