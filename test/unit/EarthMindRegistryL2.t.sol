// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "@axelar/interfaces/IAxelarGateway.sol";

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {EarthMindRegistryL2Tester} from "@contracts/test/EarthMindRegistryL2Tester.sol";

import {StringUtils} from "@contracts/libraries/StringUtils.sol";
import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";

import {Configuration} from "@config/Configuration.sol";

import {MockProvider} from "@contracts/mocks/MockProvider.sol";

import {MinerNotRegistered, ValidatorNotRegistered, InvalidSetupData} from "@contracts/Errors.sol";

import {BaseRegistryTest} from "../helpers/BaseRegistryTest.sol";

import "forge-std/console2.sol";

contract EarthMindRegistryL2Test is BaseRegistryTest {
    using StringUtils for string;
    using AddressUtils for address;

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
    function test_registerProtocol_when_receiving_message() public {
        vm.expectEmit(true, false, false, true);

        emit ProtocolRegistered(protocol1.addr());

        _registerProtocolViaMessage();

        assertEq(earthMindRegistryL2.protocols(protocol1.addr()), true);
    }

    function test_unRegisterProtocol_when_receiving_message() public {
        _registerProtocolViaMessage();

        vm.expectEmit(true, false, false, true);

        emit ProtocolUnregistered(protocol1.addr());

        _unRegisterProtocolViaMessage();

        assertEq(earthMindRegistryL2.protocols(protocol1.addr()), false);
    }

    function test_registerValidator_when_receiving_message() public {
        vm.expectEmit(true, false, false, true);

        emit ValidatorRegistered(validator1.addr());

        _registerValidatorViaMessage();

        assertEq(earthMindRegistryL2.validators(validator1.addr()), true);
    }

    function test_registerMiner_when_receiving_message() public {
        vm.expectEmit(true, false, false, true);

        emit MinerRegistered(miner1.addr());

        _registerMinerViaMessage();

        assertEq(earthMindRegistryL2.miners(miner1.addr()), true);
    }

    // test unregistering a miner

    // @dev due to coverage limitations we create a Tester contract to test the internal function _setupData
    function test_when_setupData_is_wrong_reverts() public {
        // @dev we deploy a Tester instance
        EarthMindRegistryL2Tester testerInstance =
            new EarthMindRegistryL2Tester(crosschainSetup, address(axelarGatewayMock), address(axelarGasServiceMock));

        // @dev we deploy a wrong CrossChainSetup instance
        vm.startPrank(DEPLOYER);

        CrossChainSetup newCrosschainSetup = new CrossChainSetup(DEPLOYER);

        newCrosschainSetup.setup("0", "0", address(0), address(0));

        vm.stopPrank();

        // @dev we try to call the setup data with wrong data to validate
        CrossChainSetup.SetupData memory wrongSetupData = newCrosschainSetup.getSetupData();

        vm.expectRevert(InvalidSetupData.selector);

        testerInstance.setupDataWrapper(wrongSetupData);
    }

    // @dev due to coverage limitations we create a Tester contract to test the internal function _setupData
    function test_when_setupData_is_correct() public {
        // @dev we deploy a Tester instance
        EarthMindRegistryL2Tester testerInstance =
            new EarthMindRegistryL2Tester(crosschainSetup, address(axelarGatewayMock), address(axelarGasServiceMock));

        testerInstance.setupDataWrapper(crosschainSetup.getSetupData());

        assertEq(earthMindRegistryL2.DESTINATION_CHAIN(), config.destinationChain);
        assertEq(earthMindRegistryL2.DESTINATION_ADDRESS().toAddress(), address(earthMindRegistryL1));
    }

    // External functions
    function test_unRegisterMiner() public {
        _registerMinerViaMessage();

        vm.expectEmit(true, false, false, true);

        emit MinerUnregistered(miner1.addr());

        miner1.unRegisterMiner{value: 1 ether}();

        assertEq(earthMindRegistryL1.miners(miner1.addr()), false);
    }

    function test_unRegisterMiner_when_not_registered_reverts() public {
        bytes memory registerError = abi.encodeWithSelector(MinerNotRegistered.selector, miner1.addr());

        vm.expectRevert(registerError);

        miner1.unRegisterMiner{value: 1 ether}();
    }

    function test_unRegisterValidator() public {
        _registerValidatorViaMessage();

        vm.expectEmit(true, false, false, true);

        emit ValidatorUnregistered(validator1.addr());

        validator1.unRegisterValidator{value: 1 ether}();

        assertEq(earthMindRegistryL1.validators(validator1.addr()), false);
    }

    function test_unRegisterValidator_when_not_registered_reverts() public {
        bytes memory registerError = abi.encodeWithSelector(ValidatorNotRegistered.selector, validator1.addr());

        vm.expectRevert(registerError);

        validator1.unRegisterValidator{value: 1 ether}();
    }

    // Internal functions

    function _unRegisterProtocolViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_unRegisterProtocol(address)", protocol1.addr());
        bytes32 commandId = keccak256(payload);

        _sendMessage(commandId, payload);
    }

    function _registerProtocolViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_registerProtocol(address)", protocol1.addr());
        bytes32 commandId = keccak256(payload);

        _sendMessage(commandId, payload);
    }

    function _registerMinerViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_registerMiner(address)", miner1.addr());
        bytes32 commandId = keccak256(payload);

        _sendMessage(commandId, payload);
    }

    function _registerValidatorViaMessage() internal {
        bytes memory payload = abi.encodeWithSignature("_registerValidator(address)", validator1.addr());
        bytes32 commandId = keccak256(payload);

        _sendMessage(commandId, payload);
    }

    function _sendMessage(bytes32 _commandId, bytes memory _payload) internal {
        // @dev Be aware that the source chain is the L2 chain in reality but since we are using just 1 chain for unit testing we use the
        // destination chain as the source chain (in this case the L2 becomes the source chain)
        earthMindRegistryL2.execute(
            _commandId, config.destinationChain, address(earthMindRegistryL1).toString(), _payload
        );
    }
}
