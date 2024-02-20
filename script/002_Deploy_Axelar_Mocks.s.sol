// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

// import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
// import {MockGateway} from "@contracts/mocks/MockGateway.sol";

// import {Configuration} from "@config/Configuration.sol";

// import {Script, console2} from "forge-std/Script.sol";

// contract DeployAxelarMockScript is Script {
//     function run() public {
//         vm.broadcast();

//         Create2Deployer create2Deployer = new Create2Deployer();

//         // calculate the address of mock gateway
//         bytes memory mockGatewayCreationCode = abi.encodePacked(type(MockGateway).creationCode);

//         address mockGatewayComputedAddress =
//             create2Deployer.computeAddress(Configuration.SALT, keccak256(mockGatewayCreationCode));

//         console2.logAddress(mockGatewayComputedAddress);
//     }
// }
