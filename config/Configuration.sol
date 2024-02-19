// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ConfigurationLocal} from "./Configuration.local.sol";
import {ConfigurationMainnet} from "./Configuration.mainnet.sol";
import {ConfigurationTestnet} from "./Configuration.testnet.sol";

import {Constants} from "@constants/Constants.sol";

library Configuration {
    struct ConfigValues {
        bytes32 salt;
        string sourceChain;
        string destinationChain;
        address axelarGateway;
        address axelarGasService;
    }

    function getConfiguration(uint256 _networkId) external pure returns (ConfigValues memory) {
        if (_networkId == Constants.MAINNET_NETWORK) {
            return ConfigurationMainnet.getConfig();
        }

        if (_networkId == Constants.TESTNET_NETWORK) {
            return ConfigurationTestnet.getConfig();
        }

        if (_networkId == Constants.LOCAL_NETWORK) {
            return ConfigurationLocal.getConfig();
        }

        revert("Configuration: network not supported");
    }
}
