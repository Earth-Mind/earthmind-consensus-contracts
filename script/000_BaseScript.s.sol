// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Configuration} from "@config/Configuration.sol";

import {Script, console2} from "forge-std/Script.sol";

contract BaseScript is Script {
    Configuration.ConfigValues internal config;
    address internal deployer;

    struct Deployment {
        string name;
        address addr;
    }

    string internal deploymentsPath;
    string internal folderPath;

    constructor() {
        string memory networkId = vm.envString("NETWORK_ID");
        config = _loadConfig(networkId);
        deployer = _loadDeployerInfo();

        // setup paths
        string memory root = vm.projectRoot();
        deploymentsPath = string.concat(root, "/deployments/");

        folderPath = string.concat(deploymentsPath, networkId);
    }

    function _loadConfig(string memory _networkId) private pure returns (Configuration.ConfigValues memory) {
        return Configuration.getConfiguration(_networkId);
    }

    function _loadDeployerInfo() private returns (address) {
        uint256 deployerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC"), 0);

        return vm.rememberKey(deployerPrivateKey);
    }

    function _loadCreate2DeployerAddress() internal view returns (address) {
        console2.log("Loading Create2Deployer address");

        string memory filePath = string.concat(folderPath, "/Create2Deployer.json");
        string memory jsonData = vm.readFile(filePath);

        bytes memory json = vm.parseJson(jsonData, ".address");
        address result = abi.decode(json, (address));

        console2.log("Create2Deployer address", result);

        return result;
    }

    function _loadCrosschainSetupAddress() internal view returns (address) {
        console2.log("Loading CrosschainSetup address");

        string memory filePath = string.concat(folderPath, "/CrossChainSetup.json");
        string memory jsonData = vm.readFile(filePath);

        bytes memory json = vm.parseJson(jsonData, ".address");
        address result = abi.decode(json, (address));

        console2.log("CrossChainSetup address", result);

        return result;
    }

    function _exportDeployment(string memory _name, address _addr) internal {
        console2.log("Exporting deployment");

        console2.log("Creating directory if it doesn't exists", folderPath);

        string[] memory inputs = new string[](3);
        inputs[0] = "mkdir";
        inputs[1] = "-p";
        inputs[2] = folderPath;

        vm.ffi(inputs);

        console2.log("Exporting deployment");

        string memory filePath = string.concat(folderPath, "/", _name, ".json");

        string memory finalJson = vm.serializeAddress("address", "address", _addr);

        vm.writeJson(finalJson, filePath);
    }
}
