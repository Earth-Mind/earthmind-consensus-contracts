// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AxelarExecutable} from "@axelar/executable/AxelarExecutable.sol";
import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";

import {EarthMindRegistryL2} from "./EarthMindRegistryL2.sol";
import {TimeBasedEpochs} from "./TimeBasedEpochs.sol";
import {CrossChainSetup} from "./CrossChainSetup.sol";

import {
    InvalidValidator,
    InvalidMiner,
    InvalidProposal,
    InvalidTopMinerProposal,
    ProposalAlreadyCommitted,
    ProposalAlreadyRevealed,
    ProposalNotCommitted,
    TopMinerProposalAlreadyCommitted,
    TopMinerProposalAlreadyRevealed,
    TopMinerProposalNotCommitted,
    InvalidSourceChain,
    InvalidSourceAddress
} from "./Errors.sol";

import {StringUtils} from "./libraries/StringUtils.sol";

contract EarthMindConsensus is TimeBasedEpochs, AxelarExecutable {
    using StringUtils for string;

    IAxelarGasService public immutable gasReceiver;

    EarthMindRegistryL2 public registry;

    struct MinerProposal {
        bytes32 proposalHash;
        bool isRevealed;
        bool vote;
        string message; // @improve: Remove this from the struct and just emit it in the event
    }

    struct TopMinersProposal {
        bytes32 topMinersProposalHash;
        bool isRevealed;
        address[] minerAddresses;
    }

    struct Request {
        address sender;
        bytes32 proposalId;
    }

    mapping(uint256 epoch => mapping(address => MinerProposal)) public minerProposals;
    mapping(uint256 epoch => mapping(address => TopMinersProposal)) public validatorProposals;

    // TODO Give rewards when win during epoch
    mapping(address miner => uint256 rewardsBalance) public rewardsBalance;

    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    // L1 Governance Requests
    event RequestReceived(uint256 indexed epoch, address indexed sender, bytes32 message);

    constructor(address _registryL2, address _gateway, address _gasService) AxelarExecutable(_gateway) {
        gasReceiver = IAxelarGasService(_gasService);

        registry = EarthMindRegistryL2(_registryL2);
    }

    // Miner Operations
    function commitProposal(uint256 _epoch, bytes32 _proposalHash)
        external
        onlyMiners
        atStage(_epoch, Stage.CommitMiners)
    {
        MinerProposal storage proposal = minerProposals[_epoch][msg.sender];

        if (proposal.proposalHash != 0) {
            revert ProposalAlreadyCommitted(msg.sender);
        }

        proposal.proposalHash = _proposalHash;

        emit ProposalCommitted(_epoch, msg.sender, _proposalHash);
    }

    function revealProposal(uint256 _epoch, bool _vote, string calldata _message)
        external
        onlyMiners
        atStage(_epoch, Stage.RevealMiners)
    {
        MinerProposal storage proposal = minerProposals[_epoch][msg.sender];

        if (proposal.isRevealed) {
            revert ProposalAlreadyRevealed(msg.sender);
        }

        if (proposal.proposalHash == 0) {
            revert ProposalNotCommitted(msg.sender);
        }

        bytes32 hashedProposal = keccak256(abi.encodePacked(msg.sender, _epoch, _vote, _message));

        if (hashedProposal != proposal.proposalHash) {
            revert InvalidProposal(msg.sender);
        }

        proposal.isRevealed = true;
        // store the vote
        emit ProposalRevealed(_epoch, msg.sender, _vote, _message);
    }

    // Validator Operations
    function commitScores(uint256 _epoch, bytes32 _topMinersProposalHash)
        external
        onlyValidators
        atStage(_epoch, Stage.CommitValidators)
    {
        TopMinersProposal storage topMinerProposal = validatorProposals[_epoch][msg.sender];
        if (topMinerProposal.topMinersProposalHash != 0) {
            revert TopMinerProposalAlreadyCommitted(msg.sender);
        }

        topMinerProposal.topMinersProposalHash = _topMinersProposalHash;

        emit TopMinersProposalCommitted(_epoch, msg.sender, _topMinersProposalHash);
    }

    function revealScores(uint256 _epoch, address[] calldata _minerAddresses)
        external
        onlyValidators
        atStage(_epoch, Stage.RevealValidators)
    {
        // TODO: duplicated miners

        // TODO: How do we know validators are passing miner addresses that are actually miners?
        // Maybe a merkle tree of miner addresses?
        TopMinersProposal storage topMinerProposal = validatorProposals[_epoch][msg.sender];

        if (topMinerProposal.isRevealed) {
            revert TopMinerProposalAlreadyRevealed(msg.sender);
        }

        if (topMinerProposal.topMinersProposalHash == 0) {
            revert TopMinerProposalNotCommitted(msg.sender);
        }

        bytes32 computedTopMinersProposalHash = keccak256(abi.encodePacked(msg.sender, _epoch, _minerAddresses));

        if (computedTopMinersProposalHash != topMinerProposal.topMinersProposalHash) {
            revert InvalidTopMinerProposal(msg.sender);
        }

        topMinerProposal.isRevealed = true;
        topMinerProposal.minerAddresses = _minerAddresses;

        emit TopMinersProposalRevealed(_epoch, msg.sender, _minerAddresses);

        // structure => epoch => miner => score
        // As validators are revealing their scores, we add the scores for each miner...
    }

    // Internal Functions
    function _requestGovernanceDecision(bytes memory _payload) internal {
        totalEpochs++;
        Request memory request = abi.decode(_payload, (Request));

        epochs[totalEpochs] = Epoch({
            startTime: block.timestamp,
            endTime: block.timestamp + MinerCommitPeriod + MinerRevealPeriod + ValidatorCommitPeriod + ValidatorRevealPeriod
                + SettlementPeriod,
            proposalId: request.proposalId,
            sender: request.sender
        });

        emit RequestReceived(totalEpochs, request.sender, request.proposalId);
    }

    function _execute(string calldata sourceChain, string calldata sourceAddress, bytes calldata _payload)
        internal
        override
    {
        // @dev this should be the protocol itself, then I should validate against the protocol list
        if (!_isValidSourceAddress(sourceAddress)) {
            revert InvalidSourceAddress();
        }

        if (!_isValidSourceChain(sourceChain)) {
            revert InvalidSourceChain();
        }

        // @dev Since the only way to request a governance decision is via cross chain message, there is no need to map functions
        _requestGovernanceDecision(_payload);
    }

    // @dev This function should be called by the protocol itself via cross chain message
    function _isValidSourceAddress(string memory sourceAddress) internal view returns (bool) {
        address addr = sourceAddress.toAddress();

        return registry.protocols(addr);
    }

    function _isValidSourceChain(string calldata sourceChain) internal view returns (bool) {
        return keccak256(abi.encodePacked(sourceChain)) == keccak256(abi.encodePacked(registry.DESTINATION_CHAIN()));
    }

    function aggregateAndPropagateDecisionFromValidatorXToY(uint256 _hint) external {
        // We have all scores

        // Take the top 10 miners

        // Propagate the decision result (all using Axelar)
    }

    // Modifiers
    modifier onlyMiners() {
        if (!registry.miners(msg.sender)) {
            revert InvalidMiner(msg.sender);
        }
        _;
    }

    modifier onlyValidators() {
        if (!registry.validators(msg.sender)) {
            revert InvalidValidator(msg.sender);
        }
        _;
    }
}
