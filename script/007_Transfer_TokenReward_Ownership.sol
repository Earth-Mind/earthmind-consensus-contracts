// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindTokenReward} from "@contracts/EarthMindTokenReward.sol";
import {Constants} from "@constants/Constants.sol";

import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {BaseScript} from "./000_BaseScript.s.sol";

import {console2} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract TransferOwnershipScript is BaseScript {
    using DeploymentUtils for Vm;

    function run() public {
        console2.log("Transfering TokenReward ownership to Consensus");
        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        address consensusAddress = vm.loadDeploymentAddress(Constants.EARTHMIND_CONSENSUS);
        address earthmindTokenRewardAddress = vm.loadDeploymentAddress(Constants.EARTHMIND_TOKEN_REWARD);

        EarthMindTokenReward(earthmindTokenRewardAddress).transferOwnership(consensusAddress);
    }
}
