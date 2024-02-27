// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// import {MockGateway} from "@contracts/mocks/MockGateway.sol";
// import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
// import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";

import {BaseIntegrationTest} from "../helpers/BaseIntegrationTest.sol";

// import {console2} from "forge-std/console2.sol";

contract MinerRegistrationIntegrationTest is BaseIntegrationTest {
    function setUp() public {
        _setUp();
        _setupAccounts();
        // mockGatewayL1 = MockGateway(gatewayAddressL1);
        // earthMindRegistryL1 = EarthMindRegistryL1(registryAddressL1);
        // earthMindRegistryL2 = EarthMindRegistryL2(registryAddressL2);
    }

    function test_MinerRegister() public {
        vm.selectFork(networkL1);

        earthMindRegistryL1.registerMiner();

        // do tx to register miner
        // bridge
        // check that the miner is registered in L2
    }
}
