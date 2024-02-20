// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

// import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
// import {EarthMindToken} from "@contracts/EarthMindToken.sol";
// import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
// import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
// import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
// import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

// import {Configuration} from "@config/Configuration.sol";

// import {Script, console2} from "forge-std/Script.sol";

// contract DeployScript is Script {
//     EarthMindToken internal earthMindTokenInstance;
//     CrossChainSetup internal crosschainSetup;
//     EarthMindRegistryL1 internal earthMindL1;
//     EarthMindRegistryL2 internal earthMindL2;
//     EarthMindConsensus internal earthMindConsensusInstance;

//     function run() public {
//         vm.broadcast();

//         Create2Deployer create2Deployer = new Create2Deployer();

//         earthMindTokenInstance = new EarthMindToken();

//         crosschainSetup = new CrossChainSetup();

//         // calculate the address of the RegistryL1 contract
//         bytes memory creationCodeL1 = abi.encodePacked(
//             type(EarthMindRegistryL1).creationCode,
//             abi.encode(crosschainSetup, Configuration.AXELAR_GATEWAY, Configuration.AXELAR_GAS_SERVICE) // Encoding all constructor arguments
//         );

//         address registryL1ComputedAddress =
//             create2Deployer.computeAddress(Configuration.SALT, keccak256(creationCodeL1));

//         // calculate the address of the RegistryL2 contract
//         bytes memory creationCodeL2 = abi.encodePacked(
//             type(EarthMindRegistryL2).creationCode,
//             abi.encode(address(crosschainSetup), Configuration.AXELAR_GATEWAY, Configuration.AXELAR_GAS_SERVICE) // Encoding all constructor arguments
//         );

//         address registryL2ComputedAddress =
//             create2Deployer.computeAddress(Configuration.SALT, keccak256(creationCodeL2));

//         // setup the crosschain setup contract with the addresses of the registry contracts
//         crosschainSetup.setup(
//             Configuration.SOURCE_CHAIN,
//             Configuration.DESTINATION_CHAIN,
//             registryL1ComputedAddress,
//             registryL2ComputedAddress
//         );

//         // deploy the registry contracts
//         address deployedAddressOfRegistryL1 = create2Deployer.deploy(0, Configuration.SALT, creationCodeL1);
//         address deployedAddressOfRegistryL2 = create2Deployer.deploy(0, Configuration.SALT, creationCodeL2);

//         earthMindL1 = EarthMindRegistryL1(deployedAddressOfRegistryL1);
//         earthMindL2 = EarthMindRegistryL2(deployedAddressOfRegistryL2);

//         // deploy consensus contract
//         earthMindConsensusInstance = new EarthMindConsensus(
//             address(earthMindL2),
//             Configuration.AXELAR_GATEWAY,
//             Configuration.AXELAR_GAS_SERVICE
//         );
//     }
// }
