//SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "@axelar/interfaces/IAxelarGateway.sol";

import {MessageRelayer} from "@contracts/messaging/MessageRelayer.sol";

import {BaseRegistryTest} from "../../helpers/BaseRegistryTest.sol";

// @dev Since the MessageRelayer contract checks the registry, we need to test it in the context of the registry
contract MessageRelayerTest is BaseRegistryTest {
    string constant DESTINATION_CHAIN = "base";
    string constant DESTINATION_MESSAGE_RECEIVER_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    string constant RECEIVER_SOURCE_ADDRESS = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";

    MessageRelayer internal relayer;

    event MessageSent(address indexed sender, string destinationChain, string destinationAddress, bytes payload);

    function setUp() public {
        _setUp();

        // setup mocks
        axelarGasServiceMock.when(IAxelarGasService.payNativeGasForContractCall.selector).thenReturns(abi.encode(true));

        axelarGatewayMock.when(IAxelarGateway.callContract.selector).thenReturns(abi.encode(true));

        relayer =
            new MessageRelayer(address(earthMindRegistryL1), address(axelarGatewayMock), address(axelarGasServiceMock));
    }

    function test_sendMessage() public {
        address protocolAddress = protocol1.addr();

        protocol1.registerProtocol{value: 1 ether}();

        assertEq(earthMindRegistryL1.protocols(protocol1.addr()), true);

        vm.expectEmit(true, false, false, true);

        emit MessageSent(protocolAddress, DESTINATION_CHAIN, DESTINATION_MESSAGE_RECEIVER_ADDRESS, abi.encode(""));

        relayer.sendMessage(DESTINATION_CHAIN, DESTINATION_MESSAGE_RECEIVER_ADDRESS, abi.encode(""));
    }

    function test_sendMessage_when_protocol_is_not_whitelisted_reverts() public {
        assertEq(earthMindRegistryL1.protocols(protocol1.addr()), false);

        vm.expectRevert("MessageRelayer: protocol not whitelisted");

        relayer.sendMessage(DESTINATION_CHAIN, DESTINATION_MESSAGE_RECEIVER_ADDRESS, abi.encode(""));
    }

    // NoGasPaymentProvided test (when send message doesn't have money)
}
