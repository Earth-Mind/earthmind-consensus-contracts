// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ConfigurationL1Local} from "./Configuration.local.sol";
import {ConfigurationL2Local} from "./Configuration.local.sol";

import {ConfigurationMainnet} from "./Configuration.mainnet.sol";
import {ConfigurationTestnet} from "./Configuration.testnet.sol";

import {Constants} from "@constants/Constants.sol";
import {console2} from "forge-std/Script.sol";

library Configuration {
    struct ConfigValues {
        bytes32 salt;
        string sourceChain;
        string destinationChain;
        address axelarGateway;
        address axelarGasService;
    }

    function getConfiguration(string memory _networkId) external pure returns (ConfigValues memory) {
        if (keccak256(abi.encodePacked(_networkId)) == keccak256(abi.encodePacked(Constants.MAINNET_NETWORK))) {
            return ConfigurationMainnet.getConfig();
        }

        if (keccak256(abi.encodePacked(_networkId)) == keccak256(abi.encodePacked(Constants.TESTNET_NETWORK))) {
            return ConfigurationTestnet.getConfig();
        }

        if (keccak256(abi.encodePacked(_networkId)) == keccak256(abi.encodePacked(Constants.LOCAL_L1_NETWORK))) {
            return ConfigurationL1Local.getConfig();
        }

        if (keccak256(abi.encodePacked(_networkId)) == keccak256(abi.encodePacked(Constants.LOCAL_L2_NETWORK))) {
            return ConfigurationL2Local.getConfig();
        }

        console2.log("Configuration: network not supported {}", _networkId);

        revert("Configuration: network not supported");
    }
}
