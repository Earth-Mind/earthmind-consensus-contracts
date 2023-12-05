// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./BaseTest.sol";

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {EarthMindToken} from "@contracts/EarthMindToken.sol";
import {Deployer} from "@contracts/utils/Deployer.sol";

import {Configuration} from "@config/Configuration.sol";
import {MockProvider} from "../mocks/MockProvider.sol";

import "forge-std/console.sol";

contract BaseRegistryTest is BaseTest {
    // Instances
    Deployer internal deployer;
    EarthMindRegistryL1 internal earthMindL1;
    EarthMindRegistryL2 internal earthMindL2;
    CrossChainSetup internal crosschainSetup;
    EarthMindToken internal earthMindTokenInstance;

    // Accounts
    Validator internal validator1;
    Protocol internal protocol1;
    Miner internal miner1;

    address internal DEPLOYER = vm.addr(1234);

    // Mock
    MockProvider internal axelarGatewayMock;
    MockProvider internal axelarGasServiceMock;

    function _setUp() internal {
        _setupAccounts();
        _deploy();

        miner1.init(earthMindL1, earthMindL2, earthMindTokenInstance, DEPLOYER);
        validator1.init(earthMindL1, earthMindL2, earthMindTokenInstance, DEPLOYER);
        protocol1.init(earthMindL1, earthMindL2, earthMindTokenInstance, DEPLOYER);
    }

    function _setupAccounts() private {
        validator1 = new Validator("validator_1", vm);
        miner1 = new Miner("miner_1", vm);
        protocol1 = new Protocol("protocol_1", vm);
    }

    function _deploy() private {
        vm.startPrank(DEPLOYER);

        deployer = new Deployer();
        earthMindTokenInstance = new EarthMindToken();
        crosschainSetup = new CrossChainSetup();

        axelarGatewayMock = new MockProvider();
        axelarGasServiceMock = new MockProvider();

        // calculate the address of the L1 contract
        bytes memory creationCodeL1 = abi.encodePacked(
            type(EarthMindRegistryL1).creationCode,
            abi.encode(crosschainSetup, address(axelarGatewayMock), address(axelarGasServiceMock)) // Encoding all constructor arguments
        );

        address l1Address = deployer.computeAddress(Configuration.SALT, keccak256(creationCodeL1));
        console.log("L1 address: %s", l1Address);

        // calculate the address of the L2 contract
        bytes memory creationCodeL2 = abi.encodePacked(
            type(EarthMindRegistryL2).creationCode,
            abi.encode(address(crosschainSetup), address(axelarGatewayMock), address(axelarGasServiceMock)) // Encoding all constructor arguments
        );

        address l2Address = deployer.computeAddress(Configuration.SALT, keccak256(creationCodeL2));
        console.log("L2 address: %s", l2Address);

        // setup the crosschain setup contract
        crosschainSetup.setup(Configuration.SOURCE_CHAIN, Configuration.DESTINATION_CHAIN, l1Address, l2Address);

        address deployedAddressL1 = deployer.deploy(0, Configuration.SALT, creationCodeL1);
        address deployedAddressL2 = deployer.deploy(0, Configuration.SALT, creationCodeL2);

        earthMindL1 = EarthMindRegistryL1(deployedAddressL1);
        earthMindL2 = EarthMindRegistryL2(deployedAddressL2);

        vm.stopPrank();
    }
}
