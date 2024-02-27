// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseAccount} from "./BaseAccount.sol";

contract Miner is BaseAccount {
    bytes32 internal DEFAULT_PROPOSAL_ID = keccak256("proposal_id");

    struct ProposalInfo {
        bytes32 proposalId;
        bool vote;
        string message;
    }

    ProposalInfo private defaultProposal =
        ProposalInfo({proposalId: DEFAULT_PROPOSAL_ID, vote: true, message: "No issues found"});

    ProposalInfo private proposal;

    uint256 private constant DEFAULT_EPOCH = 1;
    uint256 private epoch;

    constructor(BaseAccount.AccountParams memory _params) BaseAccount(_params) {
        proposal = defaultProposal;
        epoch = DEFAULT_EPOCH;
    }

    function registerMiner() external payable {
        vm.startPrank(addr);

        if (forkMode) {
            vm.selectFork(networkL1);
        }

        earthMindRegistryL1Instance.registerMiner{value: msg.value}();

        _refreshBalances();
    }

    function unRegisterMiner() external payable {
        vm.startPrank(addr);

        if (forkMode) {
            vm.selectFork(networkL2);
        }

        earthMindRegistryL2Instance.unRegisterMiner{value: msg.value}();

        _refreshBalances();
    }

    function commitProposal() external {
        bytes32 proposalHash = calculateProposalHash(proposal);

        vm.startPrank(addr);

        if (forkMode) {
            vm.selectFork(networkL2);
        }

        earthMindConsensusInstance.commitProposal(epoch, proposalHash);

        _refreshBalances();
    }

    function revealProposal() external {
        vm.startPrank(addr);

        if (forkMode) {
            vm.selectFork(networkL2);
        }

        earthMindConsensusInstance.revealProposal(epoch, proposal.vote, proposal.message);

        _refreshBalances();
    }

    // Testing Helpers
    function setProposalInfo(bytes32 _proposalId, bool _vote, string memory _message) external {
        proposal = ProposalInfo({proposalId: _proposalId, vote: _vote, message: _message});
    }

    function getProposalInfo() internal view returns (ProposalInfo memory) {
        return proposal;
    }

    function setEpoch(uint256 _epoch) internal {
        epoch = _epoch;
    }

    function getEpoch() internal view returns (uint256) {
        return epoch;
    }

    // We consider address + epoch + vote + message as the unique identifier of a miner proposal
    function getProposalHash() external view returns (bytes32) {
        return calculateProposalHash(proposal);
    }

    function calculateProposalHash(ProposalInfo memory _proposal) public view returns (bytes32) {
        return keccak256(abi.encodePacked(addr, epoch, _proposal.vote, _proposal.message));
    }
}
