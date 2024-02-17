// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract MockGateway {
    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    function validateContractCall(bytes32, string calldata, string calldata, bytes32) external pure returns (bool) {
        return true;
    }

    function callContract(
        string calldata destinationChain,
        string calldata destinationContractAddress,
        bytes calldata payload
    ) external {
        emit ContractCall(msg.sender, destinationChain, destinationContractAddress, keccak256(payload), payload);
    }
}
