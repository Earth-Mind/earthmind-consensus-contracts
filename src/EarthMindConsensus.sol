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

    uint256 public MAX_MINERS_PER_VALIDATOR_PROPOSAL = 10;

    struct MinerProposal {
        bytes32 proposalHash;
        bool isRevealed;
        bool vote;
        string message; // @improve: Remove this from the struct and just emit it in the event
    }

    struct ValidatorProposal {
        bytes32 topMinersProposalHash;
        bool isRevealed;
        address[] minerAddresses;
    }

    struct MinerScore {
        address miner;
        uint256 score;
    }

    struct Request {
        address sender;
        bytes32 proposalId;
    }

    mapping(uint256 epoch => mapping(address => MinerProposal)) public minerProposals;
    mapping(uint256 epoch => mapping(address => ValidatorProposal)) public validatorProposals;
    mapping(address miner => uint256 rewardsBalance) public rewardsBalance; // TODO Give rewards when win during epoch
    mapping(uint256 epoch => mapping(address miner => uint256 score)) public validatorsScores;
    mapping(uint256 epoch => address[] minersAddresses) public epochMinerAddressesScored; // Mapping from epoch to an array of miner addresses for enumeration
    mapping(uint256 epoch => uint256 lastIndex) public lastProcessedIndex;
    mapping(uint256 epoch => MinerScore[10] topMiners) public epochTopMiners; // Tracks the top 10 miners for each epoch

    event MinerProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event MinerProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event ValidatorProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event ValidatorProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);
    event RequestReceived(uint256 indexed epoch, address indexed sender, bytes32 message); // L1 Governance Requests

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

        emit MinerProposalCommitted(_epoch, msg.sender, _proposalHash);
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

        // store the vote
        proposal.isRevealed = true;
        proposal.vote = _vote;
        proposal.message = _message;

        emit MinerProposalRevealed(_epoch, msg.sender, _vote, _message);
    }

    // Validator Operations
    function commitScores(uint256 _epoch, bytes32 _topMinersProposalHash)
        external
        onlyValidators
        atStage(_epoch, Stage.CommitValidators)
    {
        ValidatorProposal storage topMinerProposal = validatorProposals[_epoch][msg.sender];
        if (topMinerProposal.topMinersProposalHash != 0) {
            revert TopMinerProposalAlreadyCommitted(msg.sender);
        }

        topMinerProposal.topMinersProposalHash = _topMinersProposalHash;

        emit ValidatorProposalCommitted(_epoch, msg.sender, _topMinersProposalHash);
    }

    function revealScores(uint256 _epoch, address[] calldata _minerAddresses)
        external
        onlyValidators
        atStage(_epoch, Stage.RevealValidators)
    {
        _validateNonEmptyArray(_minerAddresses);
        _validateArrayLength(_minerAddresses);
        _validateDuplicates(_minerAddresses);
        _validateAddresses(_minerAddresses);

        ValidatorProposal storage topMinerProposal = validatorProposals[_epoch][msg.sender];

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

        // store validator proposal
        topMinerProposal.isRevealed = true;
        topMinerProposal.minerAddresses = _minerAddresses;

        _addScores(_epoch, _minerAddresses);

        emit ValidatorProposalRevealed(_epoch, msg.sender, _minerAddresses);
    }

    function aggregateScoresAndPropagateDecision(uint256 _epoch, uint256 _start, uint256 _end) external {
        // TODO Have a way to know the epoch is finalized

        require(_start <= _end, "Invalid range.");
        require(_end < epochMinerAddressesScored[_epoch].length, "End index out of bounds.");

        // Ensure _start is greater than the last processed index to avoid re-processing
        uint256 processedUntil = lastProcessedIndex[_epoch];
        require(
            _start > processedUntil,
            "Start index should be greater than the last processed index or equal to process from the beginning."
        );

        for (uint256 i = _start; i <= _end; i++) {
            address miner = epochMinerAddressesScored[_epoch][i];
            uint256 score = validatorsScores[_epoch][miner];
            _insertInOrder(_epoch, miner, score);
        }

        lastProcessedIndex[_epoch] = _end; // Update to the last processed index correctly

        // Further logic to utilize or propagate top miners...
    }

    // Internal Functions
    function _insertInOrder(uint256 _epoch, address miner, uint256 score) internal {
        MinerScore[10] storage topMiners = epochTopMiners[_epoch];
        MinerScore memory newMinerScore = MinerScore(miner, score);

        int256 insertPos = -1;
        for (uint256 i = 0; i < 10; i++) {
            if (topMiners[i].miner == address(0) || topMiners[i].score < score) {
                insertPos = int256(i);
                break;
            }
        }

        if (insertPos != -1) {
            for (int256 i = 8; i >= insertPos; i--) {
                topMiners[uint256(i + 1)] = topMiners[uint256(i)];
            }
            topMiners[uint256(insertPos)] = newMinerScore;
        }
    }

    function _addOrUpdateScore(uint256 _epoch, address _miner) internal {
        if (validatorsScores[_epoch][_miner] == 0) {
            // New score for this miner in this epoch, add miner address to array for tracking
            epochMinerAddressesScored[_epoch].push(_miner);
        }

        validatorsScores[_epoch][_miner] += 1;
    }

    function _addScores(uint256 _epoch, address[] calldata _minerAddresses) internal {
        for (uint256 i = 0; i < _minerAddresses.length; i++) {
            _addOrUpdateScore(_epoch, _minerAddresses[i]);
        }
    }

    function _validateNonEmptyArray(address[] calldata _minerAddresses) internal view {
        if (_minerAddresses.length == 0) {
            revert InvalidTopMinerProposal(msg.sender);
        }
    }

    function _validateArrayLength(address[] calldata _minerAddresses) internal view {
        if (_minerAddresses.length > MAX_MINERS_PER_VALIDATOR_PROPOSAL) {
            revert InvalidTopMinerProposal(msg.sender);
        }
    }

    function _validateDuplicates(address[] calldata _minerAddresses) internal pure {
        for (uint256 i = 0; i < _minerAddresses.length; i++) {
            for (uint256 j = i + 1; j < _minerAddresses.length; j++) {
                require(_minerAddresses[i] != _minerAddresses[j], "Duplicate address detected");
            }
        }
    }

    function _validateAddresses(address[] calldata _minerAddresses) internal view {
        for (uint256 i = 0; i < _minerAddresses.length; i++) {
            if (!registry.miners(_minerAddresses[i])) {
                revert InvalidMiner(_minerAddresses[i]);
            }
        }
    }

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
