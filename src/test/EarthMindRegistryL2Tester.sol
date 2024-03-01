// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CrossChainSetup} from "../CrossChainSetup.sol";

import "../EarthMindRegistryL2.sol";

contract EarthMindRegistryL2Tester is EarthMindRegistryL2 {
    constructor(CrossChainSetup _setup, address _gateway, address _gasService)
        EarthMindRegistryL2(_setup, _gateway, _gasService)
    {}

    function setupDataWrapper(CrossChainSetup.SetupData memory setupData) external {
        _setupData(setupData);
    }
}
