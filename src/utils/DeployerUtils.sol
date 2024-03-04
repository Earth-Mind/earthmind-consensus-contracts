// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

/*
 * @title DeployerUtils
 * @dev Library intended to extend Vm with deployer address loading capabilities.
 *
 * To use it:
 * import { DeployerUtils } from "@utils/DeployerUtils.sol";
 *
 * Then implement the library
 * using DeployerUtils for Vm;
 *
 * Finally you can use the library methods like:
 * vm.getDeployerAddress();
 */
library DeployerUtils {
    function loadDeployerAddress(Vm vm) internal returns (address) {
        console2.log("Loading Deployer address");

        uint256 deployerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC"), 0);

        return vm.rememberKey(deployerPrivateKey);
    }
}
