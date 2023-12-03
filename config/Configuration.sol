// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Configuration {
    string public constant SOURCE_CHAIN = "5"; // Goerli for testing
    string public constant DESTINATION_CHAIN = "1313161555"; // Aurora testnet for testing
    address public constant AXELAR_GATEWAY = 0xe432150cce91c13a887f7D836923d5597adD8E31;
    address public constant AXELAR_GAS_SERVICE = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;
}
