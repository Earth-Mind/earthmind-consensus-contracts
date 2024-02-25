// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployRegistryL2Script is BaseScript {
    using DeploymentUtils for Vm;

    function run() public {
        console2.log("Deploying Registry L2 contracts");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(_loadCreate2DeployerAddress());

        address crosschainSetupAddress = _loadCrosschainSetupAddress();

        // calculate the address of the RegistryL2 contract
        bytes memory creationCodeL2 = abi.encodePacked(
            type(EarthMindRegistryL2).creationCode,
            abi.encode(crosschainSetupAddress, config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );

        address registryL2ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL2));

        console2.log("Computed address of EarthMindRegistryL2");
        console2.logAddress(registryL2ComputedAddress);

        // deploy the registry contracts
        address deployedAddressOfRegistryL2 = create2Deployer.deploy(0, config.salt, creationCodeL2);

        assert(deployedAddressOfRegistryL2 == registryL2ComputedAddress);

        vm.saveDeploymentAddress("EarthMindRegistryL2", deployedAddressOfRegistryL2);
    }
}
