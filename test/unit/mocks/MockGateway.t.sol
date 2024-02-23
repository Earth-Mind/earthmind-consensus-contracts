// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {MockGateway} from "@contracts/mocks/MockGateway.sol";

import "forge-std/Test.sol";

contract MockGatewayTest is Test {
    MockGateway instance;

    address deployer = vm.addr(1234);

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    function setUp() public {
        vm.prank(deployer);
        instance = new MockGateway();
    }

    function test_validateContractCall() public {
        assertEq(instance.validateContractCall(bytes32(0), "", "", bytes32(0)), true);
    }

    function test_callContract() public {
        string memory destinationChain = "arbitrum";
        string memory destinationContractAddress = "0x1234567890AbCdEf1234567890abcdef12345678";
        bytes memory payload = abi.encodePacked("payload");

        vm.expectEmit(true, false, false, true);

        emit ContractCall(deployer, destinationChain, destinationContractAddress, keccak256(payload), payload);

        vm.prank(deployer);

        instance.callContract(destinationChain, destinationContractAddress, payload);

        MockGateway.ContractCallParams memory lastContractCall = instance.getLastContractCall();

        assertEq(lastContractCall.sender, deployer);
        assertEq(lastContractCall.destinationChain, destinationChain);
        assertEq(lastContractCall.destinationContractAddress, destinationContractAddress);
        assertEq(lastContractCall.payloadHash, keccak256(payload));
        assertEq(lastContractCall.payload, payload);
    }
}
