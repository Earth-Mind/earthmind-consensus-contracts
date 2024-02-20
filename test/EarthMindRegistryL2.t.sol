// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "@axelar/interfaces/IAxelarGateway.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";

import {Configuration} from "@config/Configuration.sol";

import {MockProvider} from "@contracts/mocks/MockProvider.sol";

import {BaseRegistryTest} from "./helpers/BaseRegistryTest.sol";

import "forge-std/console2.sol";

contract EarthMindRegistryL2Test is BaseRegistryTest {
    event MinerUnregistered(address indexed Miner);
    event ValidatorUnregistered(address indexed Validator);

    // via message from Axelar Gateway
    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);

    function setUp() public {
        _setUp();

        // setup mocks
        axelarGasServiceMock.when(IAxelarGasService.payNativeGasForContractCall.selector).thenReturns(abi.encode(true));

        axelarGatewayMock.when(IAxelarGateway.callContract.selector).thenReturns(abi.encode(true));

        // @dev only used for interactions where the L1 has to message the L2
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));
    }

    // Internal functions
    function test_registerProtocol_whenReceivingMessage() public {
        vm.expectEmit(true, false, false, true);

        emit ProtocolRegistered(protocol1.addr());

        _registerProtocolViaMessage();

        assertEq(earthMindL2.protocols(protocol1.addr()), true);
    }

    function test_unRegisterProtocol_whenReceivingMessage() public {
        _registerProtocolViaMessage();

        vm.expectEmit(true, false, false, true);

        emit ProtocolUnregistered(protocol1.addr());

        _unRegisterProtocolViaMessage();

        assertEq(earthMindL2.protocols(protocol1.addr()), false);
    }

    function test_registerValidator_whenReceivingMessage() public {
        vm.expectEmit(true, false, false, true);

        emit ValidatorRegistered(validator1.addr());

        _registerValidatorViaMessage();

        assertEq(earthMindL2.validators(validator1.addr()), true);
    }

    function test_registerMiner_whenReceivingMessage() public {
        vm.expectEmit(true, false, false, true);

        emit MinerRegistered(miner1.addr());

        _registerMinerViaMessage();

        assertEq(earthMindL2.miners(miner1.addr()), true);
    }

    // External functions
    function test_MinerUnRegister() public {
        _registerMinerViaMessage();

        vm.expectEmit(true, false, false, true);

        emit MinerUnregistered(miner1.addr());

        miner1.unRegisterMiner{value: 1 ether}();

        assertEq(earthMindL1.miners(miner1.addr()), false);
    }

    function test_ValidatorUnRegister() public {
        _registerValidatorViaMessage();

        vm.expectEmit(true, false, false, true);

        emit ValidatorUnregistered(validator1.addr());

        validator1.unRegisterValidator{value: 1 ether}();

        assertEq(earthMindL1.validators(validator1.addr()), false);
    }

    function _unRegisterProtocolViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_unRegisterProtocol(address)", protocol1.addr());
        bytes32 commandId = keccak256(payload);

        earthMindL2.execute(commandId, config.sourceChain, Strings.toHexString(address(earthMindL1)), payload);
    }

    function _registerProtocolViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_registerProtocol(address)", protocol1.addr());
        bytes32 commandId = keccak256(payload);

        earthMindL2.execute(commandId, config.sourceChain, Strings.toHexString(address(earthMindL1)), payload);
    }

    function _registerMinerViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_registerMiner(address)", miner1.addr());
        bytes32 commandId = keccak256(payload);

        earthMindL2.execute(commandId, config.sourceChain, Strings.toHexString(address(earthMindL1)), payload);
    }

    function _registerValidatorViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_registerValidator(address)", validator1.addr());
        bytes32 commandId = keccak256(payload);

        earthMindL2.execute(commandId, config.sourceChain, Strings.toHexString(address(earthMindL1)), payload);
    }
}
