// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";

contract DeployRegistryL1Script is BaseScript {
    function run() public {
        console2.log("Deploying Registry L1 contracts");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(_loadCreate2DeployerAddress());

        address crosschainSetupAddress = _loadCrosschainSetupAddress();

        // calculate the address of the RegistryL1 contract
        bytes memory creationCodeL1 = abi.encodePacked(
            type(EarthMindRegistryL1).creationCode,
            abi.encode(crosschainSetupAddress, config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );

        address registryL1ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL1));

        console2.log("Computed address of EarthMindRegistryL1");
        console2.logAddress(registryL1ComputedAddress);

        // deploy the registry contracts
        address deployedAddressOfRegistryL1 = create2Deployer.deploy(0, config.salt, creationCodeL1);

        assert(deployedAddressOfRegistryL1 == registryL1ComputedAddress);

        _exportDeployment("EarthMindRegistryL1", deployedAddressOfRegistryL1);
    }
}
