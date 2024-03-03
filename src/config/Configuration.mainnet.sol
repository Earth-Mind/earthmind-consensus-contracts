// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {Configuration} from "./Configuration.sol";

// @dev Values https://docs.axelar.dev/resources/contract-addresses/mainnet
library ConfigurationMainnetSourceChain {
    string private constant SOURCE_CHAIN = "1"; // Ethereum mainnet
    string private constant DESTINATION_CHAIN = "8453"; // Base
    address private constant AXELAR_GATEWAY = 0x4F4495243837681061C4743b74B3eEdf548D56A5;
    address private constant AXELAR_GAS_SERVICE = 0x2d5d7d31F671F86C782533cc367F14109a082712;

    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues(SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}

library ConfigurationMainnetDestinationChain {
    string private constant SOURCE_CHAIN = "8453"; // Base
    string private constant DESTINATION_CHAIN = "1"; // Ethereum mainnet
    address private constant AXELAR_GATEWAY = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address private constant AXELAR_GAS_SERVICE = 0x2d5d7d31F671F86C782533cc367F14109a082712;

    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues(SOURCE_CHAIN, DESTINATION_CHAIN, AXELAR_GATEWAY, AXELAR_GAS_SERVICE);
    }
}
