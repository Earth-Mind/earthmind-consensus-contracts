// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "@axelar/interfaces/IAxelarGateway.sol";

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {NoGasPaymentProvided, InvalidSourceAddress, InvalidSourceChain} from "@contracts/Errors.sol";
import {Configuration} from "@config/Configuration.sol";
import {StringUtils} from "@contracts/libraries/StringUtils.sol";
import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";

import {MockProvider} from "@contracts/mocks/MockProvider.sol";

import {BaseRegistryTest} from "../helpers/BaseRegistryTest.sol";

import "forge-std/console2.sol";

contract EarthMindRegistryL1Test is BaseRegistryTest {
    using StringUtils for string;
    using AddressUtils for address;

    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);

    // via message from Axelar Gateway
    event MinerUnregistered(address indexed Miner);
    event ValidatorUnregistered(address indexed Validator);

    function setUp() public {
        _setUp();

        // setup mocks
        axelarGasServiceMock.when(IAxelarGasService.payNativeGasForContractCall.selector).thenReturns(abi.encode(true));

        axelarGatewayMock.when(IAxelarGateway.callContract.selector).thenReturns(abi.encode(true));
    }

    function test_initialProperties() public {
        assertEq(address(earthMindRegistryL1.gasReceiver()), address(axelarGasServiceMock));

        assertEq(earthMindRegistryL1.DESTINATION_CHAIN(), config.destinationChain);
        assertEq(earthMindRegistryL1.DESTINATION_ADDRESS().toAddress(), address(earthMindRegistryL2));
    }

    function test_protocolRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ProtocolRegistered(protocol1.addr());

        protocol1.registerProtocol{value: 1 ether}();

        assertEq(earthMindRegistryL1.protocols(protocol1.addr()), true);
    }

    function test_protocolRegister_when_no_ether_provided_reverts() public {
        vm.expectRevert(NoGasPaymentProvided.selector);

        protocol1.registerProtocol();
    }

    function test_protocolUnRegister() public {
        protocol1.registerProtocol{value: 1 ether}();

        vm.expectEmit(true, false, false, true);

        emit ProtocolUnregistered(protocol1.addr());

        protocol1.unRegisterProtocol{value: 1 ether}();

        assertEq(earthMindRegistryL1.protocols(protocol1.addr()), false);
    }

    function test_minerRegister() public {
        vm.expectEmit(true, false, false, true);

        emit MinerRegistered(miner1.addr());

        miner1.registerMiner{value: 1 ether}();

        assertEq(earthMindRegistryL1.miners(miner1.addr()), true);
    }

    function test_validatorRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ValidatorRegistered(validator1.addr());

        validator1.registerValidator{value: 1 ether}();

        assertEq(earthMindRegistryL1.validators(validator1.addr()), true);
    }

    function test_validatorUnregister_whenL2Messages() public {
        // @dev only used for interactions where the L2 has to message the L1
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));

        bytes memory payload = abi.encodeWithSignature("_unRegisterValidator(address)", validator1.addr());
        bytes32 commandId = keccak256(payload);

        vm.expectEmit(true, false, false, true);

        emit ValidatorUnregistered(validator1.addr());

        earthMindRegistryL1.execute(
            commandId, config.destinationChain, address(earthMindRegistryL2).toString(), payload
        );
    }

    function test_validatorUnregister_whenL2Messages_sourceAddress_is_wrong_reverts() public {
        // @dev only used for interactions where the L2 has to message the L1
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));

        bytes memory payload = abi.encodeWithSignature("_unRegisterValidator(address)", validator1.addr());
        bytes32 commandId = keccak256(payload);

        vm.expectRevert(InvalidSourceAddress.selector);

        earthMindRegistryL1.execute(
            commandId, config.destinationChain, address(earthMindRegistryL1).toString(), payload
        );
    }

    function test_validatorUnregister_whenL2Messages_sourceChain_is_wrong_reverts() public {
        // @dev only used for interactions where the L2 has to message the L1
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));

        bytes memory payload = abi.encodeWithSignature("_unRegisterValidator(address)", validator1.addr());
        bytes32 commandId = keccak256(payload);

        vm.expectRevert(InvalidSourceChain.selector);

        earthMindRegistryL1.execute(commandId, "1", address(earthMindRegistryL2).toString(), payload);
    }

    function test_minerUnregister_whenL2Messages() public {
        // @dev only used for interactions where the L2 has to message the L1
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));

        bytes memory payload = abi.encodeWithSignature("_unRegisterMiner(address)", miner1.addr());
        bytes32 commandId = keccak256(payload);

        vm.expectEmit(true, false, false, true);

        emit MinerUnregistered(miner1.addr());

        earthMindRegistryL1.execute(
            commandId, config.destinationChain, address(earthMindRegistryL2).toString(), payload
        );
    }
}
