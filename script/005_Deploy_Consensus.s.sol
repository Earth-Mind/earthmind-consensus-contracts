// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployConsensusScript is BaseScript {
    using DeploymentUtils for Vm;

    EarthMindConsensus internal earthMindConsensusInstance;

    function run() public {
        console2.log("Deploying Consensus contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(_loadCreate2DeployerAddress());

        address earthmindRegistryL2Address = _loadRegistryL2Address();

        bytes memory consensusCreationCode = abi.encodePacked(
            type(EarthMindConsensus).creationCode,
            abi.encode(earthmindRegistryL2Address, config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );

        address consensusComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(consensusCreationCode));

        console2.log("Computed address of EarthMindConsensus");
        console2.logAddress(consensusComputedAddress);

        // deploy the consensus contract
        address deployedAddressOfConsensus = create2Deployer.deploy(0, config.salt, consensusCreationCode);

        assert(deployedAddressOfConsensus == consensusComputedAddress);

        vm.saveDeploymentAddress("EarthMindConsensus", deployedAddressOfConsensus);
    }
}
