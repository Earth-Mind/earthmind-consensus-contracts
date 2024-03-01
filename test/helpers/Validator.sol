// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseAccount} from "./BaseAccount.sol";

contract Validator is BaseAccount {
    bytes32 internal DEFAULT_PROPOSAL_ID = keccak256("proposal_id");

    struct ProposalInfo {
        bytes32 proposalId;
        address[] minerAddresses;
    }

    ProposalInfo private defaultProposal =
        ProposalInfo({proposalId: DEFAULT_PROPOSAL_ID, minerAddresses: new address[](0)});

    ProposalInfo private proposal;

    uint256 private constant DEFAULT_EPOCH = 1;
    uint256 private epoch;

    constructor(BaseAccount.AccountParams memory _params) BaseAccount(_params) {
        proposal = defaultProposal;
        epoch = DEFAULT_EPOCH;
    }

    function registerValidator() external payable {
        vm.startPrank(addr);
        earthMindRegistryL1Instance.registerValidator{value: msg.value}();
        _refreshBalances();
    }

    function unRegisterValidator() external payable {
        vm.startPrank(addr);
        earthMindRegistryL2Instance.unRegisterValidator{value: msg.value}();
        _refreshBalances();
    }

    // fix params sent to commitScores
    function commitScores() external {
        vm.startPrank(addr);
        earthMindConsensusInstance.commitScores(epoch, calculateProposalHash(proposal));
        _refreshBalances();
    }

    // fix params sent to revealScores
    function revealScores() external {
        vm.startPrank(addr);
        earthMindConsensusInstance.revealScores(epoch, proposal.minerAddresses);
        _refreshBalances();
    }

    // Testing Helpers
    function setProposalInfo(bytes32 _proposalId, address[] memory minerAddresses) external {
        proposal = ProposalInfo({proposalId: _proposalId, minerAddresses: minerAddresses});
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

    // We consider address + epoch + miner addresses as the unique identifier of a miner proposal
    function getProposalHash() external view returns (bytes32) {
        return calculateProposalHash(proposal);
    }

    function calculateProposalHash(ProposalInfo memory _proposal) public view returns (bytes32) {
        return keccak256(abi.encodePacked(addr, epoch, _proposal.minerAddresses));
    }
}
