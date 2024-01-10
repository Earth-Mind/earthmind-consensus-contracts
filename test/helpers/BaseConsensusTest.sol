// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseRegistryTest} from "./BaseRegistryTest.sol";

import {Strings} from "@openzeppelin/utils/Strings.sol";

import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

import {Configuration} from "@config/Configuration.sol";

// @dev This contract is used to test the consensus contract
// It inherits from BaseRegistryTest to have access to the whole BaseRegistry setup.
contract BaseConsensusTest is BaseRegistryTest {
    EarthMindConsensus internal earthMindConsensusInstance;

    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    // @dev We override the _setUp function to deploy the consensus contract and use the overriden _getConsensusAddress function.
    function _setUp() internal virtual override {
        _deploy();

        earthMindConsensusInstance =
            new EarthMindConsensus(address(earthMindL2), address(axelarGatewayMock), address(axelarGasServiceMock));

        _setupAccounts();
    }

    function _getConsensusAddress() internal view override returns (address) {
        return address(earthMindConsensusInstance);
    }

    function _registerProtocolViaMessage(address _protocolAddress) internal {
        bytes memory payload = abi.encodeWithSignature("_registerProtocol(address)", _protocolAddress);
        bytes32 commandId = keccak256(payload);

        earthMindL2.execute(commandId, Configuration.SOURCE_CHAIN, Strings.toHexString(address(earthMindL1)), payload);
    }

    function _registerMinerViaMessage(address _minerAddress) internal {
        bytes memory payload = abi.encodeWithSignature("_registerMiner(address)", _minerAddress);
        bytes32 commandId = keccak256(payload);

        earthMindL2.execute(commandId, Configuration.SOURCE_CHAIN, Strings.toHexString(address(earthMindL1)), payload);
    }

    function _registerValidatorViaMessage(address _validatorAddress) internal {
        bytes memory payload = abi.encodeWithSignature("_registerValidator(address)", _validatorAddress);
        bytes32 commandId = keccak256(payload);

        earthMindL2.execute(commandId, Configuration.SOURCE_CHAIN, Strings.toHexString(address(earthMindL1)), payload);
    }
}
