// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {BaseConsensusTest} from "./helpers/BaseConsensusTest.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

contract EarthMindConsensusTest is BaseConsensusTest {
    function setUp() public {
        _setup();
    }

    function test_initialProperties() public {
        assertEq(address(earthMindConsensusInstance.registry()), address(earthMindL2));
    }

    function test_commitProposal_when_minerSubmitsProposal() public {
        // bytes32 proposalHash = bytes32(0x1234);

        // earthMindConsensus.commitProposal(0, proposalHash);

        // assertEq(earthMindConsensus.minerProposals(0, miner1.address()).proposalHash, proposalHash);
    }

    function test_revealProposal_when_minerRevealsProposal() public {}

    function test_commitScore_when_validatorCommits() public {}

    function test_revealScore_when_validatorCommits() public {}
}
