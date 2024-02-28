// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Miner} from "../helpers/Miner.sol";

import {BaseIntegrationTest} from "../helpers/BaseIntegrationTest.sol";

import {console2} from "forge-std/console2.sol";

contract MinerRegistrationIntegrationTest is BaseIntegrationTest {
    Miner internal miner1;

    function setUp() public {
        _setUp();

        vm.selectFork(networkL1);

        _setupAccounts();

        miner1 = miners[0];
    }

    function test_MinerRegister() public {
        miner1.registerMiner{value: 1 ether}();

        // TODO: Assert in the L2 registry
    }
}
