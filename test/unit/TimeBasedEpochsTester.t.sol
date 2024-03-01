// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {TimeBasedEpochsTester} from "@contracts/test/TimeBasedEpochsTester.sol";
import {TimeBasedEpochs} from "@contracts/TimeBasedEpochs.sol";

import {BaseTest} from "../helpers/BaseTest.sol";

contract TimeBasedEpochsTesterTest is BaseTest {
    TimeBasedEpochsTester public timeBasedEpochsTester;

    address SENDER = address(0x1);

    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    function setUp() public {
        timeBasedEpochsTester = new TimeBasedEpochsTester();
    }

    function test_initialProperties() public {
        assertEq(timeBasedEpochsTester.totalEpochs(), 0);
        assertEq(uint256(timeBasedEpochsTester.getEpochStage(0)), uint256(TimeBasedEpochs.Stage.NonStarted));
        assertEq(timeBasedEpochsTester.getMinerCommitPeriod(), 5 minutes);
        assertEq(timeBasedEpochsTester.getMinerRevealPeriod(), 5 minutes);
        assertEq(timeBasedEpochsTester.getValidatorCommitPeriod(), 5 minutes);
        assertEq(timeBasedEpochsTester.getValidatorRevealPeriod(), 5 minutes);
    }

    function test_commitProposal() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        assertEq(timeBasedEpochsTester.getEpoch(epoch).startTime, block.timestamp);

        vm.expectEmit(true, true, false, true);

        emit ProposalCommitted(epoch, SENDER, bytes32(0x0));

        vm.prank(SENDER);
        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));
    }

    function test_commitProposal_when_epoch_hasnt_started_reverts() public {
        uint256 epoch = 1;

        vm.expectRevert("Not at required stage");

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");
    }

    function test_revealProposal_when_commit_hasnt_finished_reverts() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        vm.expectRevert("Not at required stage");

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");
    }

    function test_revealProposal() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealMiners));

        vm.expectEmit(true, true, false, true);

        emit ProposalRevealed(epoch, SENDER, true, "No issues found");

        vm.prank(SENDER);

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");
    }

    function test_commitTopMinersProposal_when_miner_reveal_hasnt_finished_reverts() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealMiners));

        vm.expectRevert("Not at required stage");

        timeBasedEpochsTester.commitTopMinersProposal(epoch, bytes32(0x0));
    }

    function test_commitTopMinersProposal() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealMiners));

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitValidators));

        vm.expectEmit(true, true, false, true);

        emit TopMinersProposalCommitted(epoch, SENDER, bytes32(0x0));

        vm.prank(SENDER);

        timeBasedEpochsTester.commitTopMinersProposal(epoch, bytes32(0x0));
    }

    function test_revealTopMinersProposal() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealMiners));

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitValidators));

        timeBasedEpochsTester.commitTopMinersProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealValidators));

        address[] memory minerAddresses = new address[](1);

        minerAddresses[0] = address(0x0);

        vm.expectEmit(true, true, false, true);

        emit TopMinersProposalRevealed(epoch, SENDER, minerAddresses);

        vm.prank(SENDER);

        timeBasedEpochsTester.revealTopMinersProposal(epoch, minerAddresses);
    }

    function test_revealTopMinersProposal_when_commit_hasnt_finished_reverts() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        // commit miner
        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealMiners));

        // reveal miner
        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitValidators));

        // commit top miners proposal
        timeBasedEpochsTester.commitTopMinersProposal(epoch, bytes32(0x0));

        address[] memory minerAddresses = new address[](1);

        minerAddresses[0] = address(0x0);

        vm.expectRevert("Not at required stage");

        timeBasedEpochsTester.revealTopMinersProposal(epoch, minerAddresses);
    }

    function test_stageEnded() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        _increaseTimeBy(25 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.Ended));
    }
}
