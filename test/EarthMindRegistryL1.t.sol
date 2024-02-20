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

contract EarthMindRegistryL1Test is BaseRegistryTest {
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

    function test_ProtocolRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ProtocolRegistered(protocol1.addr());

        protocol1.registerProtocol{value: 1 ether}();

        assertEq(earthMindL1.protocols(protocol1.addr()), true);
    }

    function test_ProtocolUnRegister() public {
        protocol1.registerProtocol{value: 1 ether}();

        vm.expectEmit(true, false, false, true);

        emit ProtocolUnregistered(protocol1.addr());

        protocol1.unRegisterProtocol{value: 1 ether}();

        assertEq(earthMindL1.protocols(protocol1.addr()), false);
    }

    function test_MinerRegister() public {
        vm.expectEmit(true, false, false, true);

        emit MinerRegistered(miner1.addr());

        miner1.registerMiner{value: 1 ether}();

        assertEq(earthMindL1.miners(miner1.addr()), true);
    }

    function test_ValidatorRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ValidatorRegistered(validator1.addr());

        validator1.registerValidator{value: 1 ether}();

        assertEq(earthMindL1.validators(validator1.addr()), true);
    }

    function test_ValidatorUnregister_whenL2Messages() public {
        // @dev only used for interactions where the L2 has to message the L1
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));

        bytes memory payload = abi.encodeWithSignature("_unRegisterValidator(address)", validator1.addr());
        bytes32 commandId = keccak256(payload);

        vm.expectEmit(true, false, false, true);

        emit ValidatorUnregistered(validator1.addr());

        earthMindL1.execute(commandId, config.destinationChain, Strings.toHexString(address(earthMindL2)), payload);
    }

    function test_MinerUnregister_whenL2Messages() public {
        // @dev only used for interactions where the L2 has to message the L1
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));

        bytes memory payload = abi.encodeWithSignature("_unRegisterMiner(address)", miner1.addr());
        bytes32 commandId = keccak256(payload);

        vm.expectEmit(true, false, false, true);

        emit MinerUnregistered(miner1.addr());

        earthMindL1.execute(commandId, config.destinationChain, Strings.toHexString(address(earthMindL2)), payload);
    }
}
