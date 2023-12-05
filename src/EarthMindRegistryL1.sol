// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Strings} from "@openzeppelin/utils/Strings.sol";

import {EarthMindRegistry} from "./EarthMindRegistry.sol";
import {CrossChainSetup} from "./CrossChainSetup.sol";

import {NoGasPaymentProvided} from "./Errors.sol";

contract EarthMindRegistryL1 is EarthMindRegistry {
    constructor(CrossChainSetup _setup, address _gateway, address _gasService)
        EarthMindRegistry(_setup, _gateway, _gasService)
    {
        functionMappings[bytes4(keccak256("_unRegisterMiner(address)"))] = _unRegisterMiner;
        functionMappings[bytes4(keccak256("_unRegisterValidator(address)"))] = _unRegisterValidator;
    }

    // Override functions

    function _setupData(CrossChainSetup.SetupData memory setupData) internal override {
        DESTINATION_CHAIN = setupData.destinationChain;
        DESTINATION_ADDRESS = Strings.toHexString(setupData.registryL2);
    }

    // External functions

    function registerProtocol() external payable {
        _validateProtocolRegistration(msg.sender);

        super._registerProtocol(msg.sender);

        _bridge(abi.encodeWithSignature("registerProtocol(address)", msg.sender), msg.sender);
    }

    function unRegisterProtocol() external payable {
        _validateProtocolUnRegistration(msg.sender);

        super._unRegisterProtocol(msg.sender);

        _bridge(abi.encodeWithSignature("unRegisterProtocol(address)", msg.sender), msg.sender);
    }

    function registerMiner() external payable {
        _validateMinerRegistration(msg.sender);

        super._registerMiner(msg.sender);

        _bridge(abi.encodeWithSignature("registerMiner(address)", msg.sender), msg.sender);
    }

    function registerValidator() external payable {
        _validateValidatorRegistration(msg.sender);

        super._registerValidator(msg.sender);

        _bridge(abi.encodeWithSignature("registerValidator(address)", msg.sender), msg.sender);
    }

    // Validating functions

    function _validateProtocolRegistration(address protocol) internal view {
        require(!protocols[protocol], "Protocol already registered");

        // TODO: implement logic and increase validation conditions
    }

    function _validateProtocolUnRegistration(address protocol) internal view {
        require(protocols[protocol], "Protocol not registered");

        // TODO: implement logic and increase validation conditions
    }

    function _validateMinerRegistration(address miner) internal view {
        require(!miners[miner], "Miner already registered");

        // TODO: implement logic and increase validation conditions
    }

    function _validateValidatorRegistration(address validator) internal view {
        require(!validators[validator], "Validator already registered");

        // TODO: implement logic and increase validation conditions
    }
}
