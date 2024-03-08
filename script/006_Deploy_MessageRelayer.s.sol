// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {MessageRelayer} from "@contracts/messaging/MessageRelayer.sol";
import {Constants} from "@constants/Constants.sol";

import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployMessageRelayerScript is BaseScript {
    using DeploymentUtils for Vm;

    function run() public {
        console2.log("Deploying DeployMessageRelaye contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(vm.loadDeploymentAddress(Constants.CREATE2_DEPLOYER));

        address crosschainSetupAddress = vm.loadDeploymentAddress(Constants.CROSS_CHAIN_SETUP);
        address l1RegistryAddress = vm.loadDeploymentAddress(Constants.EARTHMIND_REGISTRY_L1);

        bytes memory messageRelayerCreationCode = abi.encodePacked(
            type(MessageRelayer).creationCode,
            abi.encode(l1RegistryAddress, config.axelarGateway, config.axelarGasService) // Encoding all constructor arguments
        );

        address messageRelayerComputedAddress =
            create2Deployer.computeAddress(Constants.SALT, keccak256(messageRelayerCreationCode));

        console2.log("Computed address of MessageRelayer");
        console2.logAddress(messageRelayerComputedAddress);

        // deploy the MessageRelayer contract
        address deployedAddressOfMessageRelayer = create2Deployer.deploy(0, Constants.SALT, messageRelayerCreationCode);

        assert(deployedAddressOfMessageRelayer == messageRelayerComputedAddress);

        vm.saveDeploymentAddress(Constants.MESSAGE_RELAYER, deployedAddressOfMessageRelayer);
    }
}
