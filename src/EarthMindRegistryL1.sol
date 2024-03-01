// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistry} from "./EarthMindRegistry.sol";
import {CrossChainSetup} from "./CrossChainSetup.sol";

import {AddressUtils} from "./libraries/AddressUtils.sol";

import {
    ProtocolAlreadyRegistered,
    ProtocolNotRegistered,
    MinerAlreadyRegistered,
    ValidatorAlreadyRegistered,
    InvalidSetupData
} from "./Errors.sol";

contract EarthMindRegistryL1 is EarthMindRegistry {
    using AddressUtils for address;

    constructor(CrossChainSetup _setup, address _gateway, address _gasService)
        EarthMindRegistry(_setup, _gateway, _gasService)
    {
        functionMappings[bytes4(keccak256("_unRegisterMiner(address)"))] = _unRegisterMiner;
        functionMappings[bytes4(keccak256("_unRegisterValidator(address)"))] = _unRegisterValidator;
    }

    // Override functions

    function _setupData(CrossChainSetup.SetupData memory setupData) internal override {
        if (
            keccak256(abi.encode(setupData.destinationChain)) == keccak256(abi.encode(0))
                || setupData.registryL2 == address(0)
        ) {
            revert InvalidSetupData();
        }
        DESTINATION_CHAIN = setupData.destinationChain;
        DESTINATION_ADDRESS = setupData.registryL2.toString();
    }

    // External functions

    function registerProtocol() external payable {
        _validateProtocolRegistration(msg.sender);

        super._registerProtocol(msg.sender);

        _bridge(abi.encodeWithSignature("_registerProtocol(address)", msg.sender), msg.sender);
    }

    function unRegisterProtocol() external payable {
        _validateProtocolUnRegistration(msg.sender);

        super._unRegisterProtocol(msg.sender);

        _bridge(abi.encodeWithSignature("_unRegisterProtocol(address)", msg.sender), msg.sender);
    }

    function registerMiner() external payable {
        _validateMinerRegistration(msg.sender);

        super._registerMiner(msg.sender);

        _bridge(abi.encodeWithSignature("_registerMiner(address)", msg.sender), msg.sender);
    }

    function registerValidator() external payable {
        _validateValidatorRegistration(msg.sender);

        super._registerValidator(msg.sender);

        _bridge(abi.encodeWithSignature("_registerValidator(address)", msg.sender), msg.sender);
    }

    // Validating functions

    function _validateProtocolRegistration(address _protocol) internal view {
        if (protocols[_protocol]) {
            revert ProtocolAlreadyRegistered(_protocol);
        }

        // TODO: implement logic and increase validation conditions
    }

    function _validateProtocolUnRegistration(address _protocol) internal view {
        if (!protocols[_protocol]) {
            revert ProtocolNotRegistered(_protocol);
        }

        // TODO: implement logic and increase validation conditions
    }

    function _validateMinerRegistration(address _miner) internal view {
        if (miners[_miner]) {
            revert MinerAlreadyRegistered(_miner);
        }

        // TODO: implement logic and increase validation conditions
    }

    function _validateValidatorRegistration(address _validator) internal view {
        if (validators[_validator]) {
            revert ValidatorAlreadyRegistered(_validator);
        }
        // TODO: implement logic and increase validation conditions
    }
}
