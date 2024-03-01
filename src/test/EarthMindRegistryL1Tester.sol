// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CrossChainSetup} from "../CrossChainSetup.sol";

import "../EarthMindRegistryL1.sol";

contract EarthMindRegistryL1Tester is EarthMindRegistryL1 {
    constructor(CrossChainSetup _setup, address _gateway, address _gasService)
        EarthMindRegistryL1(_setup, _gateway, _gasService)
    {}

    function setupDataWrapper(CrossChainSetup.SetupData memory setupData) external {
        _setupData(setupData);
    }
}
