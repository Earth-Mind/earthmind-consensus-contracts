// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";
import {MockGateway} from "@contracts/mocks/MockGateway.sol";
import {EarthMindToken} from "@contracts/EarthMindToken.sol";

import {Configuration} from "@config/Configuration.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {BaseTest} from "./BaseTest.sol";

import {Validator} from "./Validator.sol";
import {Protocol} from "./Protocol.sol";
import {Miner} from "./Miner.sol";

import {Vm} from "forge-std/Vm.sol";

contract BaseIntegrationTest is BaseTest {
    using DeploymentUtils for Vm;

    address internal DEPLOYER;

    MockGateway internal mockGatewayL1;
    MockGateway internal mockGatewayL2;

    EarthMindRegistryL1 internal earthMindRegistryL1;
    EarthMindRegistryL2 internal earthMindRegistryL2;
    EarthMindToken internal earthMindToken;

    // Accounts
    Validator internal validator1;
    Protocol internal protocol1;
    Miner internal miner1;

    Configuration.ConfigValues internal configL1;
    Configuration.ConfigValues internal configL2;

    string public constant NETWORK_L1 = "31337";
    string public constant NETWORK_L2 = "31338";

    uint256 networkL1;
    uint256 networkL2;

    address gatewayAddressL1;
    address gatewayAddressL2;

    address registryAddressL1;
    address registryAddressL2;

    address consensusAddress;

    function _setUp() internal virtual {
        networkL1 = vm.createFork("http://localhost:8555");
        networkL2 = vm.createFork("http://localhost:8556");

        // load deployment addresses
        gatewayAddressL1 = vm.loadDeploymentAddress(NETWORK_L1, "MockGateway");
        gatewayAddressL2 = vm.loadDeploymentAddress(NETWORK_L2, "MockGateway");

        registryAddressL1 = vm.loadDeploymentAddress(NETWORK_L1, "EarthMindRegistryL1");
        registryAddressL2 = vm.loadDeploymentAddress(NETWORK_L2, "EarthMindRegistryL2");

        consensusAddress = vm.loadDeploymentAddress(NETWORK_L2, "EarthMindConsensus");

        // setup instances
        earthMindRegistryL1 = EarthMindRegistryL1(registryAddressL1);
        earthMindRegistryL2 = EarthMindRegistryL2(registryAddressL2);
    }

    function _setupAccounts() internal virtual {
        validator1 = new Validator("validator_1", vm);
        miner1 = new Miner("miner_1", vm);
        protocol1 = new Protocol("protocol_1", vm);

        // TODO: Remove address 0 that refers to the EarthMindToken
        miner1.init(earthMindRegistryL1, earthMindRegistryL2, EarthMindToken(address(0)), consensusAddress, DEPLOYER);

        validator1.init(
            earthMindRegistryL1, earthMindRegistryL2, EarthMindToken(address(0)), consensusAddress, DEPLOYER
        );

        protocol1.init(earthMindRegistryL1, earthMindRegistryL2, EarthMindToken(address(0)), consensusAddress, DEPLOYER);
    }
}
