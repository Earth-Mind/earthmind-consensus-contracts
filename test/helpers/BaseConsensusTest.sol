// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseRegistryTest} from "./BaseRegistryTest.sol";

import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

// @dev This contract is used to test the consensus contract
// It inherits from BaseRegistryTest to have access to the whole BaseRegistry setup.
contract BaseConsensusTest is BaseRegistryTest {
    EarthMindConsensus internal earthMindConsensusInstance;

    function _setup() internal {
        earthMindConsensusInstance = new EarthMindConsensus(address(earthMindL2));
    }
}
