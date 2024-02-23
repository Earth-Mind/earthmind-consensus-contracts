// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/access/Ownable.sol";

import {CrossChainSetupHasBeenInitialised} from "./Errors.sol";

// @notice Contract used to setup cross chain contracts that have a dependency between them.
contract CrossChainSetup is Ownable {
    struct SetupData {
        string sourceChain;
        string destinationChain;
        address registryL1;
        address registryL2;
    }

    SetupData private setupData;
    bool public initialised;

    constructor() {
        initialised = false;
    }

    function setup(
        string memory _sourceChain,
        string memory _destinationChain,
        address _registryL1,
        address _registryL2
    ) external onlyOwner {
        if (initialised) {
            revert CrossChainSetupHasBeenInitialised();
        }

        initialised = true;

        setupData.sourceChain = _sourceChain;
        setupData.destinationChain = _destinationChain;
        setupData.registryL1 = _registryL1;
        setupData.registryL2 = _registryL2;
    }

    function getSetupData() external view returns (SetupData memory) {
        return setupData;
    }
}
