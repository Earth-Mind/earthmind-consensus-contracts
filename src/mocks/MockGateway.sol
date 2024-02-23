// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract MockGateway {
    // @dev We store the last contract call to be able to bridge the call to the second chain.
    // This is mostly used in the integration tests.
    struct ContractCallParams {
        address sender;
        string destinationChain;
        string destinationContractAddress;
        bytes32 payloadHash;
        bytes payload;
    }

    ContractCallParams private lastContractCall;

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
        lastContractCall = ContractCallParams({
            sender: msg.sender,
            destinationChain: destinationChain,
            destinationContractAddress: destinationContractAddress,
            payloadHash: keccak256(payload),
            payload: payload
        });
        emit ContractCall(msg.sender, destinationChain, destinationContractAddress, keccak256(payload), payload);
    }

    function getLastContractCall() external view returns (ContractCallParams memory) {
        return lastContractCall;
    }
}
