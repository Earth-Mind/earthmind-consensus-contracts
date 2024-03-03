// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistry} from "./EarthMindRegistry.sol";
import {CrossChainSetup} from "./CrossChainSetup.sol";

import {AddressUtils} from "./libraries/AddressUtils.sol";

import {MinerNotRegistered, ValidatorNotRegistered, InvalidSetupData} from "./Errors.sol";

contract EarthMindRegistryL2 is EarthMindRegistry {
    using AddressUtils for address;

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
        bytes32 destinationChain = keccak256(abi.encode(setupData.destinationChain));

        if (destinationChain == keccak256(abi.encode("0")) || setupData.registryL1 == address(0)) {
            revert InvalidSetupData();
        }

        DESTINATION_CHAIN = setupData.destinationChain;
        DESTINATION_ADDRESS = setupData.registryL1.toString();
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
