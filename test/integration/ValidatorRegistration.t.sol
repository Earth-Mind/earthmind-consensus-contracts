// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseRegistryTest} from "../helpers/BaseRegistryTest.sol";

import {MockGateway} from "@contracts/mocks/MockGateway.sol";

contract ValidatorRegistrationIntegrationTest is BaseRegistryTest {
    MockGateway internal mockGateway;

    function setUp() public {
        // _setUp();

        mockGateway = new MockGateway();
    }

    function test_ValidatorRegister() public {
        assertEq(true, true);
    }
}

// corro cross-anvil
// obtengo las direcciones
// creo instancias
// hago llamadas
// bridgeo
// aserto
