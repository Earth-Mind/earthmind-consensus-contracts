// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Account.sol";

contract Miner is Account {
    struct ProposalInfo {
        bool vote;
        string message;
    }

    ProposalInfo private constant defaultProposal = ProposalInfo({vote: true, message: "No issues found"});
    ProposalInfo private proposal;

    uint256 private constant DEFAULT_EPOCH = 1;
    uint256 private epoch;

    constructor(string memory _name, Vm _vm) Account(_name, _vm) {
        proposal = defaultProposal;
        epoch = DEFAULT_EPOCH;
    }

    function registerMiner() external payable {
        vm.prank(addr);
        earthMindRegistryL1Instance.registerMiner{value: msg.value}();
        _refreshBalances();
    }

    function unRegisterMiner() external payable {
        vm.prank(addr);
        earthMindRegistryL2Instance.unRegisterMiner{value: msg.value}();
        _refreshBalances();
    }

    function commitProposal() external {
        bytes32 proposalHash = getProposalHash(proposal);
        vm.prank(addr);
        earthMindConsensusInstance.commitProposal(epoch, proposalHash);
        _refreshBalances();
    }

    function revealProposal() external {
        vm.prank(addr);
        earthMindConsensusInstance.revealProposal(epoch, proposal.vote, proposal.message);
        _refreshBalances();
    }

    // Testing Helpers
    function setProposalInfo(bool _vote, string memory _message) internal {
        defaultProposal = ProposalInfo({vote: _vote, message: _message});
    }

    function getProposalInfo() internal view returns (ProposalInfo memory) {
        return defaultProposal;
    }

    function setEpoch(uint256 _epoch) internal {
        epoch = _epoch;
    }

    function getEpoch() internal view returns (uint256) {
        return epoch;
    }

    // We consider address + epoch + vote + message as the unique identifier of a miner proposal
    function getProposalHash(ProposalInfo memory _proposal) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(addr, epoch, _proposal.vote, _proposal.message));
    }
}
