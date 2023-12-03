// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistry} from "./EarthMindRegistry.sol";
import {CrossChainSetup} from "./CrossChainSetup.sol";

contract EarthMindRegistryL2 is EarthMindRegistry {
    constructor(CrossChainSetup.SetupData _setup, address _gateway, address _gasService)
        EarthMindRegistry(_setup, _gateway, _gasService)
    {}

    ///////////////////////////////////////////////////////////////////////////
    //  OVERRIDE FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////
    function _setupData(CrossChainSetup.SetupData setupData) internal view override {
        // @dev Since this is in the L2, the destionation chain is the source chain or L1
        DESTINATION_CHAIN = setupData.sourceChain;
        DESTINATION_ADDRESS = setupData.registryL1;
    }

    ///////////////////////////////////////////////////////////////////////////
    //  MESSAGING FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    function _execute(string calldata sourceChain, string calldata sourceAddress, bytes calldata payload)
        internal
        override
    {
        (uint256 nonce, bytes memory payloadActual) = abi.decode(payload, (uint256, bytes));
        gateway.callContract(sourceChain, sourceAddress, abi.encode(nonce));
        _executePostAck(sourceChain, sourceAddress, payloadActual);
    }
}
