// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./BaseTest.sol";

import {EarthMindRegistryL1} from "../src/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "../src/EarthMindRegistryL2.sol";
import {CrossChainSetup} from "../src/CrossChainSetup.sol";
import {Configuration} from "../config/Configuration.sol";

contract BaseRegistryTest is BaseTest {
    // Instances
    EarthMindRegistryL1 internal earthMindL1;
    EarthMindRegistryL2 internal earthMindL2;
    CrossChainSetup internal crosschainSetup;

    // Accounts
    Validator internal validator1;
    Protocol internal protocol1;
    Miner internal miner1;

    function _setUp() internal {
        _setupAccounts();
        _deploy();
    }

    function _setupAccounts() private {
        validator1 = new Validator("validator_1", vm);
        miner1 = new Miner("miner_1", vm);
        protocol1 = new Protocol("protocol_1", vm);
    }

    function _deploy() private {
        crosschainSetup = new CrossChainSetup();

        // calculate the address of the L1 contract
        address l1Address = address(this);

        // calculate the address of the L2 contract
        address l2Address = address(this);

        // setup the crosschain setup contract
        crosschainSetup.setup(Configuration.SOURCE_CHAIN, Configuration.DESTINATION_CHAIN, l1Address, l2Address);

        earthMindL1 = new EarthMindRegistryL1(
            crosschainSetup, Configuration.AXELAR_GATEWAY, Configuration.AXELAR_GAS_SERVICE
        );

        earthMindL2 = new EarthMindRegistryL2(
            crosschainSetup,Configuration.AXELAR_GATEWAY, Configuration.AXELAR_GAS_SERVICE
        );
    }
}
