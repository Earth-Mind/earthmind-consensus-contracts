// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../TimeBasedEpochs.sol";

// @dev This is tester contract to check the TimeBasedEpochs transitions
// The modifiers and state are ignored.
contract TimeBasedEpochsTester is TimeBasedEpochs {
    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    function commitProposal(uint256 _epoch, bytes32 _proposalHash) external atStage(_epoch, Stage.CommitMiners) {
        emit ProposalCommitted(_epoch, msg.sender, _proposalHash);
    }

    function revealProposal(uint256 _epoch, bool _vote, string memory _message)
        external
        atStage(_epoch, Stage.RevealMiners)
    {
        emit ProposalRevealed(_epoch, msg.sender, _vote, _message);
    }

    function commitTopMinersProposal(uint256 _epoch, bytes32 _topMinersProposalHash)
        external
        atStage(_epoch, Stage.CommitValidators)
    {
        emit TopMinersProposalCommitted(_epoch, msg.sender, _topMinersProposalHash);
    }

    function revealTopMinersProposal(uint256 _epoch, address[] memory _minerAddresses)
        external
        atStage(_epoch, Stage.RevealValidators)
    {
        emit TopMinersProposalRevealed(_epoch, msg.sender, _minerAddresses);
    }

    // Test Helper
    function setEpoch(uint256 _epoch) external {
        totalEpochs = _epoch;
        epochs[_epoch].startTime = block.number;
    }
}
