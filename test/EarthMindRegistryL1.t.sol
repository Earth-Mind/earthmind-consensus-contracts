// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "@axelar/interfaces/IAxelarGateway.sol";
import {BaseRegistryTest} from "./helpers/BaseRegistryTest.sol";
import {MockProvider} from "./mocks/MockProvider.sol";

contract EarthMindRegistryL1Test is BaseRegistryTest {
    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event MinerUnregistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);
    event ValidatorUnregistered(address indexed Validator);

    function setUp() public {
        _setUp();

        // setup mocks
        axelarGasServiceMock.when(IAxelarGasService.payNativeGasForContractCall.selector).thenReturns(abi.encode(true));

        axelarGatewayMock.when(IAxelarGateway.callContract.selector).thenReturns(abi.encode(true));
        //     MockProvider.Calling({functionSig: IAxelarGateway.callContract.selector, returnValue: abi.encode(true)})
        // );
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

    // function test_MinerUnRegister() public {
    //     miner1.registerMiner{value: 1 ether}();

    //     vm.expectEmit(true, false, false, true);

    //     emit MinerUnregistered(miner1.addr());

    //     miner1.unRegisterMiner{value: 1 ether}();

    //     assertEq(earthMindL1.miners(miner1.addr()), false);
    // }

    function test_ValidatorRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ValidatorRegistered(validator1.addr());

        validator1.registerValidator{value: 1 ether}();

        assertEq(earthMindL1.validators(validator1.addr()), true);
    }

    // function test_ValidatorUnRegister() public {
    //     validator1.registerValidator{value: 1 ether}();

    //     vm.expectEmit(true, false, false, true);

    //     emit ValidatorUnregistered(validator1.addr());

    //     validator1.unRegisterValidator{value: 1 ether}();

    //     assertEq(earthMindL1.validators(validator1.addr()), false);
    // }
}
