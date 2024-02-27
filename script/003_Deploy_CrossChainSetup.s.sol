// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {EarthMindTokenReward} from "@contracts/EarthMindTokenReward.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployCrossChainSetupScript is BaseScript {
    using DeploymentUtils for Vm;

    CrossChainSetup internal crosschainSetup;

    function run() public {
        console2.log("Deploying CrossChainSetup contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(vm.loadDeploymentAddress(Constants.CREATE2_DEPLOYER));

        // calculate the address of the crosschain setup contract
        bytes memory crosschainSetupCreationCode = abi.encodePacked(
            type(CrossChainSetup).creationCode,
            abi.encode(deployer) // Encoding all constructor arguments
        );

        address crosschainSetupComputedAddress =
            create2Deployer.computeAddress(config.salt, keccak256(crosschainSetupCreationCode));

        console2.log("Computed address of CrossChainSetup");
        console2.logAddress(crosschainSetupComputedAddress);

        // calculate the address of the RegistryL1 contract
        bytes memory creationCodeL1 = abi.encodePacked(
            type(EarthMindRegistryL1).creationCode,
            abi.encode(crosschainSetupComputedAddress, config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );
        address registryL1ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL1));

        // calculate the address of the RegistryL2 contract
        bytes memory creationCodeL2 = abi.encodePacked(
            type(EarthMindRegistryL2).creationCode,
            abi.encode(address(crosschainSetupComputedAddress), config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );
        address registryL2ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL2));

        // calculate the address of the Consensus contract
        bytes memory consensusCreationCode = abi.encodePacked(
            type(EarthMindConsensus).creationCode,
            abi.encode(address(crosschainSetupComputedAddress), config.axelarGateway, config.axelarGasService)
        );
        address consensusComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(consensusCreationCode));

        // calculate the address of the TokenReward contract
        bytes memory tokenRewardsCreationCode = abi.encodePacked(
            type(EarthMindTokenReward).creationCode,
            abi.encode(consensusComputedAddress) // Encoding all constructor arguments
        );
        address tokenRewardComputedAddress =
            create2Deployer.computeAddress(config.salt, keccak256(tokenRewardsCreationCode));

        // deploy the crosschain setup contract
        address deployedAddressOfCrossChainSetup = create2Deployer.deploy(0, config.salt, crosschainSetupCreationCode);

        assert(deployedAddressOfCrossChainSetup == crosschainSetupComputedAddress);

        crosschainSetup = CrossChainSetup(deployedAddressOfCrossChainSetup);

        // setup the crosschain setup contract with the addresses of the registry contracts
        crosschainSetup.setup(
            config.sourceChain,
            config.destinationChain,
            registryL1ComputedAddress,
            registryL2ComputedAddress,
            tokenRewardComputedAddress
        );

        vm.saveDeploymentAddress(Constants.CROSS_CHAIN_SETUP, deployedAddressOfCrossChainSetup);
    }
}
