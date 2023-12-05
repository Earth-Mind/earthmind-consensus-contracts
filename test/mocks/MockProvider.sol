// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "forge-std/console.sol";

contract MockProvider {
    struct ReturnData {
        // Whether the call should be successful
        bool success;
        // The data to return
        // If the call is unsuccessful, this is the reason for failure
        bytes data;
    }

    struct Calling {
        bytes4 functionSig;
        bytes returnValue;
    }

    /// @dev keccak256(query) => ReturnData
    mapping(bytes32 => ReturnData) internal _givenQueryReturn;

    /// @dev keccak256(query) => bool
    mapping(bytes32 => bool) internal _givenQuerySet;

    /// @notice Defines the return data for a given selector (msg.sig)
    /// @param _selector The `msg.data` function selector to match
    /// @param _returnData The return data to return
    function givenSelectorReturnResponse(bytes4 _selector, ReturnData memory _returnData) public {
        // Calculate the key based on the provided selector
        bytes32 queryKey = keccak256(abi.encode(_selector));

        // Save the return data for this query
        _givenQueryReturn[queryKey] = _returnData;

        // Mark the query as set
        _givenQuerySet[queryKey] = true;
    }

    function when(Calling memory _config) public {
        bytes4 selector_ = _config.functionSig;
        givenSelectorReturnResponse(selector_, ReturnData({success: true, data: _config.returnValue}));
    }

    /// @notice Handles the calls
    /// @dev Tries to match calls based on `msg.sig` and returns the corresponding return data
    fallback(bytes calldata) external payable returns (bytes memory) {
        bytes32 selectorKey = keccak256(abi.encode(msg.sig));

        if (!_givenQuerySet[selectorKey]) {
            revert("MockProvider: query not set");
        }

        bytes32 key = selectorKey;

        // Return data as specified by the query
        ReturnData memory returnData = _givenQueryReturn[key];
        require(returnData.success, string(returnData.data));

        console.log("MockProvider: returnData.data");
        console.logBytes(returnData.data);
        return returnData.data;
    }

    receive() external payable {
        revert("MockProvider: receive() not allowed");
    }
}
