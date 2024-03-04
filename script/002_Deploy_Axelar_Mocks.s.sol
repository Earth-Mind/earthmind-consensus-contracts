// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {MockGateway} from "@contracts/mocks/MockGateway.sol";
import {MockGasReceiver} from "@contracts/mocks/MockGasReceiver.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployAxelarMockScript is BaseScript {
    using DeploymentUtils for Vm;

    bool private SKIP_CONFIGURATION = true;

    function run() public {
        console2.log("Deploying AxelarMockGateway contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(vm.loadDeploymentAddress(Constants.CREATE2_DEPLOYER));

        // calculate the address of mock gateway
        bytes memory mockGatewayCreationCode = abi.encodePacked(type(MockGateway).creationCode);

        address mockGatewayComputedAddress =
            create2Deployer.computeAddress(Constants.SALT, keccak256(mockGatewayCreationCode));

        console2.log("Computed address of MockGateway");
        console2.logAddress(mockGatewayComputedAddress);

        // deploy the mock gateway contract
        address deployedAddressOfMockGateway = create2Deployer.deploy(0, Constants.SALT, mockGatewayCreationCode);

        assert(deployedAddressOfMockGateway == mockGatewayComputedAddress);

        vm.saveDeploymentAddress(Constants.MOCK_GATEWAY, deployedAddressOfMockGateway);

        // calculate the address of mock gas service
        bytes memory mockGasServiceCreationCode = abi.encodePacked(type(MockGasReceiver).creationCode);

        address mockGasServiceComputedAddress =
            create2Deployer.computeAddress(Constants.SALT, keccak256(mockGasServiceCreationCode));

        console2.log("Computed address of MockGasReceiver");
        console2.logAddress(mockGasServiceComputedAddress);

        // deploy the mock gas service contract
        address deployedAddressOfMockGasService = create2Deployer.deploy(0, Constants.SALT, mockGasServiceCreationCode);

        assert(deployedAddressOfMockGasService == mockGasServiceComputedAddress);

        vm.saveDeploymentAddress(Constants.MOCK_GAS_RECEIVER, deployedAddressOfMockGasService);
    }

    function _skipLoadConfig() internal view override returns (bool) {
        return SKIP_CONFIGURATION;
    }
}
