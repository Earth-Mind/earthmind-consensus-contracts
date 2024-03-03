// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {Configuration} from "./Configuration.sol";

// @dev Values https://docs.axelar.dev/resources/contract-addresses/testnet
library ConfigurationTestnetSourceChain {
    string private constant SOURCE_CHAIN = "11155111"; // Sepolia testnet
    string private constant DESTINATION_CHAIN = "84531"; // Base testnet
    address private constant AXELAR_GATEWAY = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address private constant AXELAR_GAS_SERVICE = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;

    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues(SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}

library ConfigurationTestnetDestinationChain {
    string private constant SOURCE_CHAIN = "84531"; // Base testnet
    string private constant DESTINATION_CHAIN = "11155111"; // Sepolia testnet
    address private constant AXELAR_GATEWAY = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address private constant AXELAR_GAS_SERVICE = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;

    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues(SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}
