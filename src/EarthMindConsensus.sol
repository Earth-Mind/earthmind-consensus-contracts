// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Strings} from "@openzeppelin/utils/Strings.sol";
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

import "forge-std/console2.sol";

contract EarthMindConsensus is TimeBasedEpochs, AxelarExecutable {
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

    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    // L1 Governance Requests
    event RequestReceived(uint256 indexed epoch, address indexed sender, bytes32 message);

    constructor(address _registry, address _gateway, address _gasService) AxelarExecutable(_gateway) {
        gasReceiver = IAxelarGasService(_gasService);

        registry = EarthMindRegistryL2(_registry);
    }

    // Miner Operations
    function commitProposal(uint256 _epoch, bytes32 _proposalHash)
        external
        onlyMiners
        atStage(_epoch, Stage.CommitMiners)
    {
        console2.log("HERE");
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

    function _requestGovernanceDecision(bytes memory _payload) internal {
        totalEpochs++;
        console2.log("Total Epochs: %s", totalEpochs);
        console2.logBytes(_payload);
        Request memory request = abi.decode(_payload, (Request));
        console2.logBytes32(request.proposalId);
        console2.logAddress(request.sender);

        console2.log("Start Time: %s", block.timestamp);

        epochs[totalEpochs] = Epoch({
            startTime: block.timestamp,
            endTime: block.timestamp + MinerCommitPeriod + MinerRevealPeriod + ValidatorCommitPeriod + ValidatorRevealPeriod
                + SettlementPeriod,
            proposalId: request.proposalId,
            sender: request.sender
        });

        emit RequestReceived(totalEpochs, request.sender, request.proposalId);
    }

    function aggregateAndPropagateDecisionFromValidatorXToY() external {
        // TODO: only when the decision has been taken....
        // TODO compute scores
    }

    function _execute(string calldata sourceChain, string calldata sourceAddress, bytes calldata _payload)
        internal
        override
    {
        // this should be the protocol itself, then I should validate against the protoco list
        if (!_isValidSourceAddress(sourceAddress)) {
            revert InvalidSourceAddress();
        }

        if (!_isValidSourceChain(sourceChain)) {
            revert InvalidSourceChain();
        }

        // @dev Since the only way to request a governance decision is via cross chain message and the only cross message from L1 to this contract is requesting a governance decision
        // There is no need to map functions
        _requestGovernanceDecision(_payload);
    }

    // function _isValidSourceAddress(string memory sourceAddress) internal view returns (bool) {
    //     console.log("Source Address 1: %s", sourceAddress);

    //     address addr;

    //     require(bytes(sourceAddress).length == 42, "Invalid address length"); // Including '0x'

    //     assembly {
    //         // Skip the first 32 bytes (length) + 2 bytes ('0x')
    //         addr := mload(add(sourceAddress, 0x24)) // 0x24 in hexadecimal is 36 in decimal
    //     }

    //     // Align the data correctly
    //     addr = address(uint160(addr >> (12 * 8)));

    //     console.log("Source Address: %s", Strings.toHexString(addr));
    //     return registry.protocols(addr);
    // }
    function _isValidSourceAddress(string memory sourceAddress) internal view returns (bool) {
        console2.log("Source Address 1: %s", sourceAddress);

        address addr = StringUtils.stringToAddress(sourceAddress);

        return registry.protocols(addr);
    }

    function _isValidSourceChain(string calldata sourceChain) internal view returns (bool) {
        return keccak256(abi.encodePacked(sourceChain)) == keccak256(abi.encodePacked(registry.DESTINATION_CHAIN()));
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
