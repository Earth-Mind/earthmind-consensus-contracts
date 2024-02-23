// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTest} from "./BaseTest.sol";

import {Validator} from "./Validator.sol";
import {Protocol} from "./Protocol.sol";
import {Miner} from "./Miner.sol";

import {Configuration} from "@config/Configuration.sol";

contract BaseIntegrationTest is BaseTest {
    // Accounts
    Validator internal validator1;
    Protocol internal protocol1;
    Miner internal miner1;

    Configuration.ConfigValues internal configL1;
    Configuration.ConfigValues internal configL2;

    function _setUp() internal virtual {}

    function _setupAccounts() internal virtual {
        validator1 = new Validator("validator_1", vm);
        miner1 = new Miner("miner_1", vm);
        protocol1 = new Protocol("protocol_1", vm);

        // address consensusAddress = _getConsensusAddress();

        // miner1.init(earthMindRegistryL1, earthMindRegistryL2, earthMindTokenInstance, consensusAddress, DEPLOYER);

        // validator1.init(earthMindRegistryL1, earthMindRegistryL2, earthMindTokenInstance, consensusAddress, DEPLOYER);

        // protocol1.init(earthMindRegistryL1, earthMindRegistryL2, earthMindTokenInstance, consensusAddress, DEPLOYER);
    }
}
