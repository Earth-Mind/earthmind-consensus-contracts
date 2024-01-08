// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {TimeBasedEpochsTester} from "@contracts/test/TimeBasedEpochsTester.sol";
import {TimeBasedEpochs} from "@contracts/TimeBasedEpochs.sol";

import {BaseTest} from "./helpers/BaseTest.sol";

contract TimeBasedEpochsTesterTest is BaseTest {
    TimeBasedEpochsTester public timeBasedEpochsTester;

    event ProposalCommitted(uint256 indexed epoch, address indexed miner, bytes32 proposalHash);
    event ProposalRevealed(uint256 indexed epoch, address indexed miner, bool vote, string message);
    event TopMinersProposalCommitted(uint256 indexed epoch, address indexed validator, bytes32 scoreHash);
    event TopMinersProposalRevealed(uint256 indexed epoch, address indexed validator, address[] minerAddresses);

    function setUp() public {
        timeBasedEpochsTester = new TimeBasedEpochsTester();
    }

    function testInitialProperties() public {
        assertEq(timeBasedEpochsTester.totalEpochs(), 0);
        assertEq(uint256(timeBasedEpochsTester.getEpochStage(0)), uint256(TimeBasedEpochs.Stage.NonStarted));
        assertEq(timeBasedEpochsTester.getMinerCommitPeriod(), 5 minutes);
        assertEq(timeBasedEpochsTester.getMinerRevealPeriod(), 5 minutes);
        assertEq(timeBasedEpochsTester.getValidatorCommitPeriod(), 5 minutes);
        assertEq(timeBasedEpochsTester.getValidatorRevealPeriod(), 5 minutes);
    }

    function testCommitProposal() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        assertEq(timeBasedEpochsTester.getEpoch(epoch).startTime, block.timestamp);

        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));
    }

    function testCommitProposal_whenEpochHasntStarted_reverts() public {
        uint256 epoch = 1;

        vm.expectRevert("Not at required stage");

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");
    }

    function testRevealProposal_whenCommitHasntFinished_reverts() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        vm.expectRevert("Not at required stage");

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");
    }

    function testRevealProposal() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealMiners));

        timeBasedEpochsTester.revealProposal(epoch, true, "No issues found");
    }

    function testCommitTopMinersProposal_whenMinerRevealHasntFinished_reverts() public {
        uint256 epoch = 1;
        timeBasedEpochsTester.setEpoch(epoch);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        timeBasedEpochsTester.commitProposal(epoch, bytes32(0x0));

        _increaseTimeBy(5 minutes);

        assertEq(uint256(timeBasedEpochsTester.getEpochStage(epoch)), uint256(TimeBasedEpochs.Stage.RevealMiners));

        vm.expectRevert("Not at required stage");

        timeBasedEpochsTester.commitTopMinersProposal(epoch, bytes32(0x0));
    }

    function testCommitTopMinersProposal() public {
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
    }

    function testRevealTopMinersProposal() public {
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

        timeBasedEpochsTester.revealTopMinersProposal(epoch, minerAddresses);
    }

    function testRevealTopMinersProposal_whenCommitHasntFinished_reverts() public {
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
}
