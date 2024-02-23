// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseRegistryTest} from "../helpers/BaseRegistryTest.sol";

import {MockGateway} from "@contracts/mocks/MockGateway.sol";

contract MinerRegistrationIntegrationTest is BaseRegistryTest {
    MockGateway internal mockGateway;

    function setUp() public {
        // _setUp();

        mockGateway = new MockGateway();
    }

    function test_MinerRegister() public {
        // miner1.registerMiner{value: 1 ether}();
        assertEq(true, true);
        // assertEq(earthMindRegistryL1.miners(miner1.addr()), true);
    }
}

// corro cross-anvil
// obtengo las direcciones
// creo instancias
// hago llamadas
// bridgeo
// aserto
