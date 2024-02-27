// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseTest} from "./BaseTest.sol";

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {Create2Deployer} from "@contracts/utils/Create2Deployer.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

import {MockProvider} from "@contracts/mocks/MockProvider.sol";

import {Configuration} from "@config/Configuration.sol";

import {BaseAccount} from "./BaseAccount.sol";
import {Validator} from "./Validator.sol";
import {Protocol} from "./Protocol.sol";
import {Miner} from "./Miner.sol";

import {console} from "forge-std/console.sol";

// @dev This contract is used to test the registry contracts
// By default we define 3 accounts per each ecosystem participant
// However, the accounts can be overwritten by the test contract that inherits from this contract.
// It also includes virtual functions that can be overwritten by the test contract.
contract BaseRegistryTest is BaseTest {
    // Instances
    MockProvider internal axelarGatewayMock;
    MockProvider internal axelarGasServiceMock;

    Create2Deployer internal create2Deployer;
    EarthMindRegistryL1 internal earthMindRegistryL1;
    EarthMindRegistryL2 internal earthMindRegistryL2;
    CrossChainSetup internal crosschainSetup;

    address internal DEPLOYER = vm.addr(1234);
    address internal EARTHMIND_CONSENSUS_ADDRESS = address(0); // @dev Since the registry doesn't require the consensus but the Account contract does it, we simply pass address(0)

    // Accounts
    Validator internal validator1;
    Protocol internal protocol1;
    Miner internal miner1;

    Configuration.ConfigValues internal config;

    function _setUp() internal virtual {
        string memory networkId = vm.envString("NETWORK_ID");

        config = Configuration.getConfiguration(networkId);

        _deploy();

        _setupAccounts();
    }

    function _deploy() internal virtual {
        vm.startPrank(DEPLOYER);

        // we deploy a deployer contract to deploy the registry contracts
        create2Deployer = new Create2Deployer();
        crosschainSetup = new CrossChainSetup(DEPLOYER);

        // setup mock providers
        axelarGatewayMock = new MockProvider();
        axelarGasServiceMock = new MockProvider();

        // calculate the address of the RegistryL1 contract
        bytes memory creationCodeL1 = abi.encodePacked(
            type(EarthMindRegistryL1).creationCode,
            abi.encode(crosschainSetup, address(axelarGatewayMock), address(axelarGasServiceMock)) // Encoding all constructor arguments
        );

        address registryL1ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL1));
        console.log("The RegistryL1 address: %s", registryL1ComputedAddress);

        // calculate the address of the RegistryL2 contract
        bytes memory creationCodeL2 = abi.encodePacked(
            type(EarthMindRegistryL2).creationCode,
            abi.encode(address(crosschainSetup), address(axelarGatewayMock), address(axelarGasServiceMock)) // Encoding all constructor arguments
        );

        address registryL2ComputedAddress = create2Deployer.computeAddress(config.salt, keccak256(creationCodeL2));
        console.log("The RegistryL2 address: %s", registryL2ComputedAddress);

        // setup the crosschain setup contract with the addresses of the registry contracts
        crosschainSetup.setup(
            config.sourceChain, config.destinationChain, registryL1ComputedAddress, registryL2ComputedAddress
        );

        // deploy the registry contracts
        address deployedAddressOfRegistryL1 = create2Deployer.deploy(0, config.salt, creationCodeL1);
        address deployedAddressOfRegistryL2 = create2Deployer.deploy(0, config.salt, creationCodeL2);

        earthMindRegistryL1 = EarthMindRegistryL1(deployedAddressOfRegistryL1);
        earthMindRegistryL2 = EarthMindRegistryL2(deployedAddressOfRegistryL2);

        console.log("BaseRegistry Deploy Done");
        vm.stopPrank();
    }

    function _setupAccounts() internal virtual {
        address consensusAddress = _getConsensusAddress();

        validator1 = new Validator(BaseAccount.AccountParams({
            name: "validator_1",
            vm: vm,
            forkMode: false,
            l1Network: 0, // since no fork mode
            l2Network: 0, // since no fork mode
            earthMindRegistryL1Instance: earthMindRegistryL1,
            earthMindRegistryL2Instance: earthMindRegistryL2,
            earthMindConsensusInstance: EarthMindConsensus(consensusAddress)
        }));

        miner1 = new Miner(BaseAccount.AccountParams({
            name: "miner_1",
            vm: vm,
            forkMode: false,
            l1Network: 0, // since no fork mode
            l2Network: 0, // since no fork mode
            earthMindRegistryL1Instance: earthMindRegistryL1,
            earthMindRegistryL2Instance: earthMindRegistryL2,
            earthMindConsensusInstance: EarthMindConsensus(consensusAddress)
        }));

        protocol1 = new Protocol(BaseAccount.AccountParams({
            name: "protocol_1",
            vm: vm,
            forkMode: false,
            l1Network: 0, // since no fork mode
            l2Network: 0, // since no fork mode
            earthMindRegistryL1Instance: earthMindRegistryL1,
            earthMindRegistryL2Instance: earthMindRegistryL2,
            earthMindConsensusInstance: EarthMindConsensus(consensusAddress)
        }));
    }

    function _getConsensusAddress() internal view virtual returns (address) {
        return EARTHMIND_CONSENSUS_ADDRESS;
    }
}
