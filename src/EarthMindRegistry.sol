// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AxelarExecutable} from "@axelar/executable/AxelarExecutable.sol";
import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";

import {CrossChainSetup} from "./CrossChainSetup.sol";

import {NoGasPaymentProvided, InvalidSourceAddress, InvalidSourceChain} from "./Errors.sol";

import "forge-std/console2.sol";

abstract contract EarthMindRegistry is AxelarExecutable {
    IAxelarGasService public immutable gasReceiver;

    string public DESTINATION_CHAIN;
    string public DESTINATION_ADDRESS;

    mapping(address protocol => bool isRegistered) public protocols;
    mapping(address miner => bool isRegistered) public miners;
    mapping(address validator => bool isRegistered) public validators;
    mapping(bytes4 => function(address) internal) internal functionMappings;

    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event MinerUnregistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);
    event ValidatorUnregistered(address indexed Validator);
    event ContractCallSent(string destinationChain, string contractAddress, bytes payload, address sender);

    constructor(CrossChainSetup _setup, address _gateway, address _gasService) AxelarExecutable(_gateway) {
        gasReceiver = IAxelarGasService(_gasService);

        _setupData(_setup.getSetupData());
    }

    // Override functions

    function _setupData(CrossChainSetup.SetupData memory setupData) internal virtual;

    // Internal functions

    function _registerProtocol(address _protocol) internal {
        protocols[_protocol] = true;

        emit ProtocolRegistered(_protocol);
    }

    function _unRegisterProtocol(address _protocol) internal {
        protocols[_protocol] = false;

        emit ProtocolUnregistered(_protocol);
    }

    function _registerMiner(address _miner) internal {
        miners[_miner] = true;

        emit MinerRegistered(_miner);
    }

    function _unRegisterMiner(address _miner) internal {
        miners[_miner] = false;

        emit MinerUnregistered(_miner);
    }

    function _registerValidator(address _validator) internal {
        validators[_validator] = true;

        emit ValidatorRegistered(_validator);
    }

    function _unRegisterValidator(address _validator) internal {
        validators[_validator] = false;

        emit ValidatorUnregistered(_validator);
    }

    // Messaging functions

    function _bridge(bytes memory _payload, address _sender) internal {
        if (msg.value == 0) {
            revert NoGasPaymentProvided();
        }

        gasReceiver.payNativeGasForContractCall{value: msg.value}(
            address(this), DESTINATION_CHAIN, DESTINATION_ADDRESS, _payload, _sender
        );

        gateway.callContract(DESTINATION_CHAIN, DESTINATION_ADDRESS, _payload);

        emit ContractCallSent(DESTINATION_CHAIN, DESTINATION_ADDRESS, _payload, _sender);
    }

    function _isValidSourceAddress(string calldata sourceAddress) internal view returns (bool) {
        return keccak256(abi.encodePacked(sourceAddress)) == keccak256(abi.encodePacked(DESTINATION_ADDRESS));
    }

    function _isValidSourceChain(string calldata sourceChain) internal view returns (bool) {
        return keccak256(abi.encodePacked(sourceChain)) == keccak256(abi.encodePacked(DESTINATION_CHAIN));
    }

    function _execute(string calldata sourceChain, string calldata sourceAddress, bytes calldata payload)
        internal
        override
    {
        if (!_isValidSourceAddress(sourceAddress)) {
            revert InvalidSourceAddress();
        }

        if (!_isValidSourceChain(sourceChain)) {
            revert InvalidSourceChain();
        }

        bytes memory payloadCopy = payload;
        bytes4 funcSelector;
        address param;

        assembly {
            // @dev Get the first 4 bytes (function signature) from payload
            funcSelector := mload(add(payloadCopy, 0x20))

            // @dev Get the parameter from payload
            param := mload(add(payloadCopy, 0x24))
        }

        functionMappings[funcSelector](param);
    }
}
