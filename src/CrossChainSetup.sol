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
        address tokenReward;
    }

    SetupData private setupData;
    bool public initialised;

    constructor(address _newOwner) {
        initialised = false;

        _transferOwnership(_newOwner);
    }

    function setup(
        string memory _sourceChain,
        string memory _destinationChain,
        address _registryL1,
        address _registryL2,
        address _tokenReward
    ) external onlyOwner {
        if (initialised) {
            revert CrossChainSetupHasBeenInitialised();
        }

        initialised = true;

        setupData.sourceChain = _sourceChain;
        setupData.destinationChain = _destinationChain;
        setupData.registryL1 = _registryL1;
        setupData.registryL2 = _registryL2;
        setupData.tokenReward = _tokenReward;
    }

    function getSetupData() external view returns (SetupData memory) {
        return setupData;
    }
}
