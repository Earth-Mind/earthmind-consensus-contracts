// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {EarthMindRegistryL1} from "../src/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "../src/EarthMindRegistryL2.sol";
import {CrosschainSetup} from "../src/CrosschainSetup.sol";
import {Configuration} from "../config/Configuration.sol";

contract EarthMindRegistryL1Test is Test {
    EarthMindRegistryL1 internal earthMindL1;
    EarthMindRegistryL2 internal earthMindL2;
    CrosschainSetup internal crosschainSetup;

    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event MinerUnregistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);
    event ValidatorUnregistered(address indexed Validator);

    function setUp() public {
        crosschainSetup = new CrosschainSetup();

        // calculate the address of the L1 contract
        address l1Address = address(this);

        // calculate the address of the L2 contract
        address l2Address = address(this);

        // setup the crosschain setup contract
        crosschainSetup.setup(Configuration.SOURCE_CHAIN, Configuration.DESTINATION_CHAIN, l1Address, l2Address);

        earthMindL1 = new EarthMindRegistryL1(
            crosschainSetup
        );

        earthMindL2 = new EarthMindRegistryL2(
            crosschainSetup
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
