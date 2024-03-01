// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";
import {Configuration} from "@config/Configuration.sol";
import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";

import {BaseRegistryTest} from "./BaseRegistryTest.sol";

import {Vm} from "forge-std/Vm.sol";

// @dev This contract is used to test the consensus contract
// It inherits from BaseRegistryTest to have access to the whole BaseRegistry setup.
contract BaseConsensusTest is BaseRegistryTest {
    using Configuration for Vm;
    using AddressUtils for address;

    EarthMindConsensus internal earthMindConsensusInstance;

    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    // @dev We override the _setUp function to deploy the consensus contract and use the overriden _getConsensusAddress function.
    function _setUp() internal virtual override {
        // @dev load the network id from the environment and get the configuration
        string memory networkId = vm.envString("NETWORK_ID");

        config = vm.getConfiguration(networkId);

        _deploy();

        earthMindConsensusInstance = new EarthMindConsensus(
            address(earthMindRegistryL2), address(axelarGatewayMock), address(axelarGasServiceMock)
        );

        _setupAccounts();
    }

    function _getConsensusAddress() internal view override returns (address) {
        return address(earthMindConsensusInstance);
    }

    function _registerProtocolViaMessage(address _protocolAddress) internal {
        bytes memory payload = abi.encodeWithSignature("_registerProtocol(address)", _protocolAddress);
        bytes32 commandId = keccak256(payload);

        _sendMessage(commandId, payload);
    }

    function _registerMinerViaMessage(address _minerAddress) internal {
        bytes memory payload = abi.encodeWithSignature("_registerMiner(address)", _minerAddress);
        bytes32 commandId = keccak256(payload);

        _sendMessage(commandId, payload);
    }

    function _registerValidatorViaMessage(address _validatorAddress) internal {
        bytes memory payload = abi.encodeWithSignature("_registerValidator(address)", _validatorAddress);
        bytes32 commandId = keccak256(payload);

        _sendMessage(commandId, payload);
    }

    function _sendMessage(bytes32 _commandId, bytes memory _payload) internal {
        // @dev Be aware that the source chain is the L2 chain in reality but since we are using just 1 chain for unit testing we use the
        // destination chain as the source chain (in this case the L2 becomes the source chain)
        earthMindRegistryL2.execute(
            _commandId, config.destinationChain, address(earthMindRegistryL1).toString(), _payload
        );
    }
}
