// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

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

        Create2Deployer create2Deployer = Create2Deployer(_loadCreate2DeployerAddress());

        // calculate the address of the crosschain setup contract
        bytes memory creationCode = abi.encodePacked(type(CrossChainSetup).creationCode);

        address computedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCode));

        console2.log("Computed address of CrossChainSetup");
        console2.logAddress(computedAddress);

        // deploy it using create2
        crosschainSetup = new CrossChainSetup();

        // calculate the address of the RegistryL1 contract
        bytes memory creationCodeL1 = abi.encodePacked(
            type(EarthMindRegistryL1).creationCode,
            abi.encode(crosschainSetup, config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );

        address registryL1ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL1));

        // calculate the address of the RegistryL2 contract
        bytes memory creationCodeL2 = abi.encodePacked(
            type(EarthMindRegistryL2).creationCode,
            abi.encode(address(crosschainSetup), config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );

        address registryL2ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL2));

        // setup the crosschain setup contract with the addresses of the registry contracts
        crosschainSetup.setup(
            config.sourceChain, config.destinationChain, registryL1ComputedAddress, registryL2ComputedAddress
        );

        // deploy the crosschain setup contract
        address deployedAddressOfCrossChainSetup = create2Deployer.deploy(0, config.salt, creationCode);

        assert(deployedAddressOfCrossChainSetup == computedAddress);

        vm.saveDeploymentAddress("CrossChainSetup", deployedAddressOfCrossChainSetup);
    }
}
