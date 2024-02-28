// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract MockGasReceiver {
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable {
        // Do nothing
    }
}
