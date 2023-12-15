// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Strings} from "@openzeppelin/utils/Strings.sol";

import {EarthMindRegistry} from "./EarthMindRegistry.sol";
import {CrossChainSetup} from "./CrossChainSetup.sol";

import {MinerNotRegistered, ValidatorNotRegistered} from "./Errors.sol";

contract EarthMindRegistryL2 is EarthMindRegistry {
    constructor(CrossChainSetup _setup, address _gateway, address _gasService)
        EarthMindRegistry(_setup, _gateway, _gasService)
    {
        // Initialize the mapping with the desired functions
        functionMappings[bytes4(keccak256("_registerProtocol(address)"))] = _registerProtocol;
        functionMappings[bytes4(keccak256("_unRegisterProtocol(address)"))] = _unRegisterProtocol;
        functionMappings[bytes4(keccak256("_registerMiner(address)"))] = _registerMiner;
        functionMappings[bytes4(keccak256("_registerValidator(address)"))] = _registerValidator;
    }

    // Override functions

    function _setupData(CrossChainSetup.SetupData memory setupData) internal override {
        // @dev Since this is in the L2, the destination chain is the source chain or L1
        DESTINATION_CHAIN = setupData.sourceChain;
        DESTINATION_ADDRESS = Strings.toHexString(setupData.registryL1);
    }

    // External functions

    function unRegisterMiner() external payable {
        _validateMinerUnRegistration(msg.sender);

        super._unRegisterMiner(msg.sender);

        _bridge(abi.encodeWithSignature("unRegisterMiner(address)", msg.sender), msg.sender);
    }

    function unRegisterValidator() external payable {
        _validateValidatorUnRegistration(msg.sender);

        super._unRegisterValidator(msg.sender);

        _bridge(abi.encodeWithSignature("unRegisterValidator(address)", msg.sender), msg.sender);
    }

    // Validating functions

    function _validateMinerUnRegistration(address _miner) internal view {
        if (!miners[_miner]) {
            revert MinerNotRegistered(_miner);
        }
        // TODO: implement logic and increase validation conditions
    }

    function _validateValidatorUnRegistration(address _validator) internal view {
        if (!validators[_validator]) {
            revert ValidatorNotRegistered(_validator);
        }
        // TODO: implement logic and increase validation conditions
    }
}
