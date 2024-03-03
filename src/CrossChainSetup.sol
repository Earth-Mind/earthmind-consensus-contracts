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

    constructor(address _newOwner) {
        initialised = false;

        _transferOwnership(_newOwner);
    }

    function setup(SetupData memory _data) external onlyOwner {
        if (initialised) {
            revert CrossChainSetupHasBeenInitialised();
        }

        initialised = true;

        setupData = _data;
    }

    function getSetupData() external view returns (SetupData memory) {
        return setupData;
    }
}
