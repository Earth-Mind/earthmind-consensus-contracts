// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {EarthMindRegistryL1} from "../src/EarthMindRegistryL1.sol";
import {Configuration} from "../config/Configuration.sol";

contract EarthMindRegistryL1Test is Test {
    EarthMindRegistryL1 public earthMindL1;

    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event MinerUnregistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);
    event ValidatorUnregistered(address indexed Validator);

    function setUp() public {
        eartMindL2 = new EarthMindRegistryL2(
            Configuration.AXELAR_GATEWAY,
            Configuration.AXELAR_GAS_SERVICE,
            Configuration.DESTINATION_CHAIN,
            Configuration.DESTINATION_ADDRESS
        );
        earthMindL1 = new EarthMindRegistryL1(
            Configuration.AXELAR_GATEWAY,
            Configuration.AXELAR_GAS_SERVICE,
            Configuration.DESTINATION_CHAIN,

        );
    }

    function test_ProtocolRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ProtocolRegistered(address(this));

        earthMindL1.registerProtocol();

        assertEq(earthMindL1.protocols(address(this)), true);
    }

    function test_ProtocolUnRegister() public {
        earthMindL1.registerProtocol();

        vm.expectEmit(true, false, false, true);

        emit ProtocolUnregistered(address(this));

        earthMindL1.unRegisterProtocol();

        assertEq(earthMindL1.protocols(address(this)), false);
    }

    function test_MinerRegister() public {
        vm.expectEmit(true, false, false, true);

        emit MinerRegistered(address(this));

        earthMindL1.registerMiner();

        assertEq(earthMindL1.miners(address(this)), true);
    }

    function test_MinerUnRegister() public {
        earthMindL1.registerMiner();

        vm.expectEmit(true, false, false, true);

        emit MinerUnregistered(address(this));

        earthMindL1.unRegisterMiner();

        assertEq(earthMindL1.miners(address(this)), false);
    }

    function test_ValidatorRegister() public {
        vm.expectEmit(true, false, false, true);

        emit ValidatorRegistered(address(this));

        earthMindL1.registerValidator();

        assertEq(earthMindL1.validators(address(this)), true);
    }

    function test_ValidatorUnRegister() public {
        earthMindL1.registerValidator();

        vm.expectEmit(true, false, false, true);

        emit ValidatorUnregistered(address(this));

        earthMindL1.unRegisterValidator();

        assertEq(earthMindL1.validators(address(this)), false);
    }
}
