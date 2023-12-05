// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "forge-std/console.sol";

contract MockProvider {
    struct ReturnData {
        bool success;
        bytes data;
    }

    mapping(bytes4 functionSignature => bytes returnData) internal mockConfigurations;
    mapping(bytes4 functionSignature => bool exists) internal mockConfigurationExists;
    bytes4 private lastFunctionSignature; // @dev We store the last specified function signature to have a chaining pattern with thenReturns()

    function when(bytes4 _functionSig) external returns (MockProvider) {
        lastFunctionSignature = _functionSig;
        return this; // @dev We return the current contract instance to have a chaining pattern with thenReturns()
    }

    function thenReturns(ReturnData memory _data) external {}

    function thenReturns(bytes memory _data) external {
        if (lastFunctionSignature == bytes4(0)) {
            revert("MockProvider: No function signature specified");
        }

        mockConfigurations[lastFunctionSignature] = _data;
        mockConfigurationExists[lastFunctionSignature] = true;

        lastFunctionSignature = bytes4(0); // Reset the current function signature
    }

    fallback(bytes calldata) external payable returns (bytes memory) {
        bytes4 selectorKey = bytes4(keccak256(abi.encode(msg.sig)));

        if (!mockConfigurationExists[selectorKey]) {
            revert("MockProvider: No configuration found for the given function signature");
        }

        // bytes returnData = mockConfigurations[selectorKey];

        // require(returnData.success, string(returnData.data));

        return mockConfigurations[selectorKey];
    }

    receive() external payable {
        revert("MockProvider: receive() not allowed");
    }
}
