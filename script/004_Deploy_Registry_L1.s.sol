// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployRegistryL1Script is BaseScript {
    using DeploymentUtils for Vm;

    function run() public {
        console2.log("Deploying Registry L1 contracts");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(vm.loadDeploymentAddress(Constants.CREATE2_DEPLOYER));

        address crosschainSetupAddress = vm.loadDeploymentAddress(Constants.CROSS_CHAIN_SETUP);

        // calculate the address of the RegistryL1 contract
        bytes memory creationCodeL1 = abi.encodePacked(
            type(EarthMindRegistryL1).creationCode,
            abi.encode(crosschainSetupAddress, config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );

        address registryL1ComputedAddress = create2Deployer.computeAddress(Constants.SALT, keccak256(creationCodeL1));

        console2.log("Computed address of EarthMindRegistryL1");
        console2.logAddress(registryL1ComputedAddress);

        // deploy the registry contracts
        address deployedAddressOfRegistryL1 = create2Deployer.deploy(0, Constants.SALT, creationCodeL1);

        assert(deployedAddressOfRegistryL1 == registryL1ComputedAddress);

        vm.saveDeploymentAddress(Constants.EARTHMIND_REGISTRY_L1, deployedAddressOfRegistryL1);
    }
}
