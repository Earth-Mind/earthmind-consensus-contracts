// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Strings} from "@openzeppelin/utils/Strings.sol";

import {EarthMindRegistry} from "./EarthMindRegistry.sol";
import {CrossChainSetup} from "./CrossChainSetup.sol";

import {InvalidSourceAddress, InvalidSourceChain} from "./Errors.sol";

contract EarthMindRegistryL2 is EarthMindRegistry {
    mapping(bytes4 => function(address) internal) private functionMappings;

    constructor(CrossChainSetup _setup, address _gateway, address _gasService)
        EarthMindRegistry(_setup, _gateway, _gasService)
    {
        // Initialize the mapping with the desired functions
        functionMappings[bytes4(keccak256("_registerProtocol(address)"))] = _registerProtocol;
        functionMappings[bytes4(keccak256("_unRegisterProtocol(address)"))] = _unRegisterProtocol;
        functionMappings[bytes4(keccak256("_registerMiner(address)"))] = _registerMiner;
        functionMappings[bytes4(keccak256("_unRegisterMiner(address)"))] = _unRegisterMiner;
        functionMappings[bytes4(keccak256("_registerValidator(address)"))] = _registerValidator;
        functionMappings[bytes4(keccak256("_unRegisterValidator(address)"))] = _unRegisterValidator;
    }

    ///////////////////////////////////////////////////////////////////////////
    //  OVERRIDE FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    function _setupData(CrossChainSetup.SetupData memory setupData) internal override {
        // @dev Since this is in the L2, the destionation chain is the source chain or L1
        DESTINATION_CHAIN = setupData.sourceChain;
        DESTINATION_ADDRESS = Strings.toHexString(setupData.registryL1);
    }

    ///////////////////////////////////////////////////////////////////////////
    //  MESSAGING FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

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

        bytes4 funcSelector = abi.decode(payload, (bytes4));
        address param = abi.decode(payload, (address));
        functionMappings[funcSelector](param);
    }

    function _isValidSourceAddress(string calldata sourceAddress) internal view returns (bool) {
        return keccak256(abi.encodePacked(sourceAddress)) == keccak256(abi.encodePacked(DESTINATION_ADDRESS));
    }

    function _isValidSourceChain(string calldata sourceChain) internal view returns (bool) {
        return keccak256(abi.encodePacked(sourceChain)) == keccak256(abi.encodePacked(DESTINATION_CHAIN));
    }
}
