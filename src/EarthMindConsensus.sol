// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistryL2} from "./EarthMindRegistryL2.sol";
import {TimeBasedEpochs} from "./TimeBasedEpochs.sol";

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
    TopMinerProposalNotCommitted
} from "./Errors.sol";

contract EarthMindConsensus is TimeBasedEpochs {
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

    mapping(uint256 epoch => mapping(address => MinerProposal)) public minerProposals;
    mapping(uint256 epoch => mapping(address => TopMinersProposal)) public validatorProposals;

    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    // L1 Governance Requests
    event RequestReceived(uint256 indexed epoch, address indexed sender, string message);

    constructor(address _registry) {
        registry = EarthMindRegistryL2(_registry);
    }

    // Miner Operations
    function commitProposal(uint256 _epoch, bytes32 _proposalHash) external onlyMiners atStage(Stage.CommitMiners) {
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
        atStage(Stage.RevealMiners)
    {
        MinerProposal storage proposal = minerProposals[_epoch][msg.sender];

        if (proposal.isRevealed) {
            revert ProposalAlreadyRevealed(msg.sender);
        }

        if (proposal.proposalHash == 0) {
            revert ProposalNotCommitted(msg.sender);
        }

        bytes32 hashedProposal = keccak256(abi.encodePacked(_epoch, msg.sender, _vote, _message));

        if (hashedProposal != proposal.proposalHash) {
            revert InvalidProposal(msg.sender);
        }

        proposal.isRevealed = true;
        // store the vote
        emit ProposalRevealed(_epoch, msg.sender, _vote, _message);
    }

    function commitScores(uint256 _epoch, bytes32 _topMinersProposalHash)
        external
        onlyValidators
        atStage(Stage.CommitValidators)
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
        atStage(Stage.RevealValidators)
    {
        // TODO: How do we know validators are passing miner addresses that are actually miners?
        // Maybe a merkle tree of miner addresses?
        TopMinersProposal storage topMinerProposal = validatorProposals[_epoch][msg.sender];

        if (topMinerProposal.isRevealed) {
            revert TopMinerProposalAlreadyRevealed(msg.sender);
        }

        if (topMinerProposal.topMinersProposalHash == 0) {
            revert TopMinerProposalNotCommitted(msg.sender);
        }

        bytes32 computedTopMinersProposalHash = keccak256(abi.encodePacked(_epoch, msg.sender, _minerAddresses));

        if (computedTopMinersProposalHash != topMinerProposal.topMinersProposalHash) {
            revert InvalidTopMinerProposal(msg.sender);
        }

        topMinerProposal.isRevealed = true;
        topMinerProposal.minerAddresses = _minerAddresses;

        emit TopMinersProposalRevealed(_epoch, msg.sender, _minerAddresses);
    }

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

    // I think I have to pass a proposal id, which is analogous to the epoch, should I rename it?
    function requestReceived(address _sender, string memory _message) external {
        currentEpoch++;

        epochs[currentEpoch] = Epoch(block.timestamp);

        emit RequestReceived(currentEpoch, _sender, _message);
    }

    function aggregateAndPropagateDecisionFromValidatorXToY() external {
        // TODO: only when the decision has been taken....
        // TODO compute scores
    }
    // validator1 -> 10 []
    // validator2 -> 10 []
    // validator3 -> 10 []
    // validator4 -> 10 []   -----> 10 []
    // validator5 -> 10 []

    // TODO proposalReceived via message
    // TODO include time manipulation...
    // when the request has started
}

// if validators just propose aggregated proposal....
// validators reports the people who gets kicked out
// Validators determine the aggregation outcome...
// No kicks for now...
// All we do is aggregate the responses from validators.....

// The dream is to do it P2P -> like a Blockchain...

// Aggregated Response of Validator
// Yes or No based on the whole miners....
// Just reward everybody

// V1
/// PoA: You have to be token holder
/// No rewards for now
/// Validators determine the aggregation outcome
/// Whitelist both sides

// validator1 -> Yes
// validator2 -> Yes
// validator3 -> Yes
// validator4 -> Yes  -----> Yes
// validator5 -> Yes
