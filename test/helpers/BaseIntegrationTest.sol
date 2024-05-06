// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";
import {MockGateway} from "@contracts/mocks/MockGateway.sol";

import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {Constants} from "@constants/Constants.sol";
import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";

import {BaseTest} from "./BaseTest.sol";

import {BaseAccount} from "./BaseAccount.sol";
import {Validator} from "./Validator.sol";
import {Protocol} from "./Protocol.sol";
import {Miner} from "./Miner.sol";

import {Vm} from "forge-std/Vm.sol";

contract BaseIntegrationTest is BaseTest {
    using DeploymentUtils for Vm;
    using AddressUtils for address;

    // Instances
    MockGateway internal mockGatewayL1;
    MockGateway internal mockGatewayL2;

    EarthMindRegistryL1 internal earthMindRegistryL1;
    EarthMindRegistryL2 internal earthMindRegistryL2;
    EarthMindConsensus internal earthMindConsensus;

    // Accounts
    Validator[] internal validators;
    Protocol[] internal protocols;
    Miner[] internal miners;

    // Forking
    uint256 internal networkL1;
    uint256 internal networkL2;

    // Addresses
    address gatewayAddressL1;
    address gatewayAddressL2;

    address registryAddressL1;
    address registryAddressL2;

    address consensusAddress;

    function _setUp() internal virtual {
        networkL1 = vm.createFork("http://localhost:8555");
        networkL2 = vm.createFork("http://localhost:8556");

        // load deployment addresses
        gatewayAddressL1 = vm.loadDeploymentAddress(Constants.LOCAL_L1_NETWORK, Constants.MOCK_GATEWAY);
        gatewayAddressL2 = vm.loadDeploymentAddress(Constants.LOCAL_L2_NETWORK, Constants.MOCK_GATEWAY);

        registryAddressL1 = vm.loadDeploymentAddress(Constants.LOCAL_L1_NETWORK, Constants.EARTHMIND_REGISTRY_L1);
        registryAddressL2 = vm.loadDeploymentAddress(Constants.LOCAL_L2_NETWORK, Constants.EARTHMIND_REGISTRY_L2);

        consensusAddress = vm.loadDeploymentAddress(Constants.LOCAL_L2_NETWORK, Constants.EARTHMIND_CONSENSUS);

        // setup instances
        earthMindRegistryL1 = EarthMindRegistryL1(registryAddressL1);
        earthMindRegistryL2 = EarthMindRegistryL2(registryAddressL2);
        earthMindConsensus = EarthMindConsensus(consensusAddress);

        mockGatewayL1 = MockGateway(gatewayAddressL1);
        mockGatewayL2 = MockGateway(gatewayAddressL2);
    }

    function _setupAccounts() internal virtual {
        Validator validator1 = new Validator(
            BaseAccount.AccountParams({
                name: "validator_1",
                vm: vm,
                forkMode: true,
                l1Network: networkL1,
                l2Network: networkL2,
                earthMindRegistryL1Instance: earthMindRegistryL1,
                earthMindRegistryL2Instance: earthMindRegistryL2,
                earthMindConsensusInstance: earthMindConsensus
            })
        );

        Miner miner1 = new Miner(
            BaseAccount.AccountParams({
                name: "miner_1",
                vm: vm,
                forkMode: true,
                l1Network: networkL1,
                l2Network: networkL2,
                earthMindRegistryL1Instance: earthMindRegistryL1,
                earthMindRegistryL2Instance: earthMindRegistryL2,
                earthMindConsensusInstance: earthMindConsensus
            })
        );

        Protocol protocol1 = new Protocol(
            BaseAccount.AccountParams({
                name: "protocol_1",
                vm: vm,
                forkMode: true,
                l1Network: networkL1,
                l2Network: networkL2,
                earthMindRegistryL1Instance: earthMindRegistryL1,
                earthMindRegistryL2Instance: earthMindRegistryL2,
                earthMindConsensusInstance: earthMindConsensus
            })
        );

        validators.push(validator1);
        miners.push(miner1);
        protocols.push(protocol1);
    }

    function _bridgeFromL1ToL2(bytes32 _commandId) internal {
        vm.selectFork(networkL1);

        MockGateway.ContractCallParams memory lastcall = mockGatewayL1.getLastContractCall();

        vm.selectFork(networkL2);

        earthMindRegistryL2.execute(
            _commandId, Constants.LOCAL_L1_NETWORK, address(earthMindRegistryL1).toString(), lastcall.payload
        );
    }

    function _bridgeFromL2ToL1(bytes32 _commandId) internal {
        vm.selectFork(networkL2);

        MockGateway.ContractCallParams memory lastcall = mockGatewayL2.getLastContractCall();

        vm.selectFork(networkL1);

        earthMindRegistryL1.execute(
            _commandId, Constants.LOCAL_L2_NETWORK, address(earthMindRegistryL2).toString(), lastcall.payload
        );
    }
}
