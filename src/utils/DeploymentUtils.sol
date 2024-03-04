// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {console2} from "forge-std/console2.sol";
import "forge-std/Vm.sol";

/*
 * @title DeploymentUtils
 * @dev Library intended to extend Vm with export deployment capabilities
 *
 * To use it:
 * import { DeploymentUtils } from "@utils/DeploymentUtils.sol";
 *
 * Then implement the library
 * using DeploymentUtils for Vm;
 *
 * Finally you can use the library methods like:
 * vm.exportDeployment("MockGateway", deployedAddressOfMockGateway);
 * or
 * vm.loadDeploymentAddress("MockGateway");
 */
library DeploymentUtils {
    function loadDeploymentAddress(Vm vm, string memory _networkId, string memory _contractName)
        internal
        view
        returns (address)
    {
        console2.log("Loading address");

        string memory folderPath = _getFolderPath(vm, _networkId);

        string memory filePath = string.concat(folderPath, "/", _contractName, ".json");
        string memory jsonData = vm.readFile(filePath);

        bytes memory json = vm.parseJson(jsonData, ".address");
        address result = abi.decode(json, (address));

        console2.log("Address loaded", result);

        return result;
    }

    function loadDeploymentAddress(Vm vm, string memory _contractName) internal view returns (address) {
        console2.log("Loading address");

        string memory networkId = vm.envString("NETWORK_ID");

        string memory folderPath = _getFolderPath(vm, networkId);

        string memory filePath = string.concat(folderPath, "/", _contractName, ".json");
        string memory jsonData = vm.readFile(filePath);

        bytes memory json = vm.parseJson(jsonData, ".address");
        address result = abi.decode(json, (address));

        console2.log("Address loaded", result);

        return result;
    }

    function saveDeploymentAddress(Vm vm, string memory _networkId, string memory _contractName, address _address)
        internal
    {
        console2.log("Exporting deployment");

        string memory folderPath = _getFolderPath(vm, _networkId);

        _createFolderIfNotExists(vm, folderPath);

        string memory filePath = string.concat(folderPath, "/", _contractName, ".json");

        string memory finalJson = vm.serializeAddress("address", "address", _address);

        vm.writeJson(finalJson, filePath);
    }

    function saveDeploymentAddress(Vm vm, string memory _contractName, address _address) internal {
        console2.log("Exporting deployment");

        string memory networkId = vm.envString("NETWORK_ID");

        string memory folderPath = _getFolderPath(vm, networkId);

        _createFolderIfNotExists(vm, folderPath);

        string memory filePath = string.concat(folderPath, "/", _contractName, ".json");

        string memory finalJson = vm.serializeAddress("address", "address", _address);

        vm.writeJson(finalJson, filePath);
    }

    function _getFolderPath(Vm vm, string memory _networkId) internal view returns (string memory) {
        string memory root = vm.projectRoot();
        string memory deploymentsPath = string.concat(root, "/deployments/");

        string memory folderPath = string.concat(deploymentsPath, _networkId);

        return folderPath;
    }

    function _createFolderIfNotExists(Vm vm, string memory _folderPath) internal {
        console2.log("Creating directory if it doesn't exists", _folderPath);

        string[] memory inputs = new string[](3);
        inputs[0] = "mkdir";
        inputs[1] = "-p";
        inputs[2] = _folderPath;

        vm.ffi(inputs);
    }
}
