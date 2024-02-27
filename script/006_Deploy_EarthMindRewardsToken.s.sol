// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {EarthMindTokenReward} from "@contracts/EarthMindTokenReward.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract DeployRewardsTokenScript is BaseScript {
    using DeploymentUtils for Vm;

    EarthMindTokenReward internal earthMindTokenReward;

    function run() public {
        console2.log("Deploying EarthMindTokenReward contract");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        Create2Deployer create2Deployer = Create2Deployer(vm.loadDeploymentAddress(Constants.CREATE2_DEPLOYER));

        address consensusAddress = vm.loadDeploymentAddress(Constants.EARTHMIND_CONSENSUS);

        // calculate the address of the token rewards contract
        bytes memory tokenRewardCreationCode =
            abi.encodePacked(type(EarthMindTokenReward).creationCode, abi.encode(consensusAddress));

        address tokenRewardsComputedAddress =
            create2Deployer.computeAddress(config.salt, keccak256(tokenRewardCreationCode));

        console2.log("Computed address of EarthMindTokenReward");
        console2.logAddress(tokenRewardsComputedAddress);

        // deploy the consensus contract
        address deployedAddressOfTokenReward = create2Deployer.deploy(0, config.salt, tokenRewardCreationCode);

        assert(deployedAddressOfTokenReward == tokenRewardsComputedAddress);

        vm.saveDeploymentAddress(Constants.EARTHMIND_TOKEN_REWARD, deployedAddressOfTokenReward);
    }
}
