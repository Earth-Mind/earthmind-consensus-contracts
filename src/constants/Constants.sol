// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Constants {
    bytes32 public constant SALT = hex"65617274686D696E64"; // earthmind
    address public constant FOUNDRY_CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    string public constant ETHEREUM_MAINNET_NETWORK = "1";
    string public constant ETHEREUM_SEPOLIA_NETWORK = "11155111";
    string public constant BASE_MAINNET_NETWORK = "8453";
    string public constant BASE_TESTNET_NETWORK = "84531";
    string public constant LOCAL_L1_NETWORK = "31337";
    string public constant LOCAL_L2_NETWORK = "31338";
    string public constant LOCAL_TEST_NETWORK = "3137";
    string public constant CREATE2_DEPLOYER = "Create2Deployer";
    string public constant MOCK_GATEWAY = "MockGateway";
    string public constant MOCK_GAS_RECEIVER = "MockGasReceiver";
    string public constant CROSS_CHAIN_SETUP = "CrossChainSetup";
    string public constant EARTHMIND_CONSENSUS = "EarthMindConsensus";
    string public constant EARTHMIND_REGISTRY_L1 = "EarthMindRegistryL1";
    string public constant EARTHMIND_REGISTRY_L2 = "EarthMindRegistryL2";
    string public constant MESSAGE_RELAYER = "MessageRelayer";
}
