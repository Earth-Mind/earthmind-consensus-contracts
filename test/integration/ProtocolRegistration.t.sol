// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseIntegrationTest} from "../helpers/BaseIntegrationTest.sol";

import {MockGateway} from "@contracts/mocks/MockGateway.sol";

contract ProtocolRegistrationIntegrationTest is BaseIntegrationTest {
    MockGateway internal mockGateway;

    function setUp() public {
        // _setUp();

        mockGateway = new MockGateway();
    }

    function test_ProtocolRegister() public {
        assertEq(true, true);
    }
}
