// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {EarthMindRegistry} from "../src/EarthMindRegistry.sol";

contract EarthMindRegistryTest is Test {
    EarthMindRegistry public instance;

    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event MinerUnregistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);
    event ValidatorUnregistered(address indexed Validator);

    function setUp() public {
        instance = new EarthMindRegistry();
    }

    function test_ProtocolRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ProtocolRegistered(address(this));

        instance.registerProtocol();

        assertEq(instance.protocols(address(this)), true);
    }

    function test_ProtocolUnRegister() public {
        instance.registerProtocol();

        vm.expectEmit(true, false, false, true);

        emit ProtocolUnregistered(address(this));

        instance.unRegisterProtocol();

        assertEq(instance.protocols(address(this)), false);
    }

    function test_MinerRegister() public {
        vm.expectEmit(true, false, false, true);

        emit MinerRegistered(address(this));

        instance.registerMiner();

        assertEq(instance.miners(address(this)), true);
    }

    function test_MinerUnRegister() public {
        instance.registerMiner();

        vm.expectEmit(true, false, false, true);

        emit MinerUnregistered(address(this));

        instance.unRegisterMiner();

        assertEq(instance.miners(address(this)), false);
    }

    function test_ValidatorRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ValidatorRegistered(address(this));

        instance.registerValidator();

        assertEq(instance.validators(address(this)), true);
    }

    function test_ValidatorUnRegister() public {
        instance.registerValidator();

        vm.expectEmit(true, false, false, true);

        emit ValidatorUnregistered(address(this));

        instance.unRegisterValidator();

        assertEq(instance.validators(address(this)), false);
    }
}
