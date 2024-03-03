// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {ConfigurationL1Local} from "./Configuration.local.sol";
import {ConfigurationL2Local} from "./Configuration.local.sol";
import {ConfigurationMainnetSourceChain, ConfigurationMainnetDestinationChain} from "./Configuration.mainnet.sol";
import {ConfigurationTestnetSourceChain, ConfigurationTestnetDestinationChain} from "./Configuration.testnet.sol";
import {ConfigurationTest} from "./Configuration.test.sol";

import {Vm} from "forge-std/Vm.sol";

library Configuration {
    struct ConfigValues {
        string sourceChain;
        string destinationChain;
        address axelarGateway;
        address axelarGasService;
    }

    function getConfiguration(Vm _vm, string memory _networkId) external view returns (ConfigValues memory) {
        bytes32 networkHash = keccak256(abi.encodePacked(_networkId));

        if (networkHash == keccak256(abi.encodePacked(Constants.ETHEREUM_MAINNET_NETWORK))) {
            return ConfigurationMainnetSourceChain.getConfig();
        }

        if (networkHash == keccak256(abi.encodePacked(Constants.BASE_MAINNET_NETWORK))) {
            return ConfigurationMainnetDestinationChain.getConfig();
        }

        if (networkHash == keccak256(abi.encodePacked(Constants.ETHEREUM_SEPOLIA_NETWORK))) {
            return ConfigurationTestnetSourceChain.getConfig();
        }

        if (networkHash == keccak256(abi.encodePacked(Constants.BASE_TESTNET_NETWORK))) {
            return ConfigurationTestnetDestinationChain.getConfig();
        }

        if (networkHash == keccak256(abi.encodePacked(Constants.LOCAL_L1_NETWORK))) {
            return ConfigurationL1Local.getConfig(_vm);
        }

        if (networkHash == keccak256(abi.encodePacked(Constants.LOCAL_L2_NETWORK))) {
            return ConfigurationL2Local.getConfig(_vm);
        }

        if (networkHash == keccak256(abi.encodePacked(Constants.LOCAL_TEST_NETWORK))) {
            return ConfigurationTest.getConfig();
        }

        revert("Configuration: network not supported");
    }
}
