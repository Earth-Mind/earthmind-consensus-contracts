// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Strings} from "@openzeppelin/utils/Strings.sol";
import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "@axelar/interfaces/IAxelarGateway.sol";

import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";
import {TimeBasedEpochs} from "@contracts/TimeBasedEpochs.sol";
import {Configuration} from "@config/Configuration.sol";

import {BaseConsensusTest} from "../helpers/BaseConsensusTest.sol";

contract EarthMindConsensusTest is BaseConsensusTest {
    bytes32 internal PROPOSAL_ID = keccak256("proposal_id");

    uint256 internal MINER_COMMIT_PERIOD = 5 minutes;
    uint256 internal MINER_REVEAL_PERIOD = 5 minutes;
    uint256 internal VALIDATOR_COMMIT_PERIOD = 5 minutes;
    uint256 internal VALIDATOR_REVEAL_PERIOD = 5 minutes;
    uint256 internal SETTLEMENT_PERIOD = 10 minutes;
    uint256 internal EPOCH_DURATION = MINER_COMMIT_PERIOD + MINER_REVEAL_PERIOD + VALIDATOR_COMMIT_PERIOD
        + VALIDATOR_REVEAL_PERIOD + SETTLEMENT_PERIOD;

    function setUp() public {
        _setUp();

        // setup mocks
        axelarGasServiceMock.when(IAxelarGasService.payNativeGasForContractCall.selector).thenReturns(abi.encode(true));

        axelarGatewayMock.when(IAxelarGateway.callContract.selector).thenReturns(abi.encode(true));

        // @dev only used for interactions where the L1 has to message the L2
        axelarGatewayMock.when(IAxelarGateway.validateContractCall.selector).thenReturns(abi.encode(true));

        // @dev we register protocol, miner and validator via messages only, since in a real world scenario they
        // would be registered by the L1 and propagated via messages to the L2
        _registerProtocolViaMessage(protocol1.addr());
        _registerMinerViaMessage(miner1.addr());
        _registerValidatorViaMessage(validator1.addr());
    }

    function test_initialProperties() public {
        assertEq(address(earthMindConsensusInstance.registry()), address(earthMindRegistryL2));

        // assert that the total epochs are 0
        assertEq(earthMindConsensusInstance.totalEpochs(), 0);

        EarthMindConsensus.Epoch memory epochResult = earthMindConsensusInstance.getEpoch(0);

        assertEq(epochResult.startTime, 0);
        assertEq(epochResult.endTime, 0);
        assertEq(epochResult.proposalId, bytes32(0));
        assertEq(epochResult.sender, address(0));

        // assert that the current stage is NonStarted for epoch 0
        assertEq(uint256(earthMindConsensusInstance.getEpochStage(0)), uint256(TimeBasedEpochs.Stage.NonStarted));

        // period getters
        assertEq(earthMindConsensusInstance.getMinerCommitPeriod(), MINER_COMMIT_PERIOD);

        assertEq(earthMindConsensusInstance.getMinerRevealPeriod(), MINER_REVEAL_PERIOD);

        assertEq(earthMindConsensusInstance.getValidatorCommitPeriod(), VALIDATOR_COMMIT_PERIOD);

        assertEq(earthMindConsensusInstance.getValidatorRevealPeriod(), VALIDATOR_REVEAL_PERIOD);

        assertEq(earthMindConsensusInstance.getSettlementPeriod(), SETTLEMENT_PERIOD);

        // assert validator exists
        assertEq(earthMindRegistryL2.validators(validator1.addr()), true);

        // assert miner exists
        assertEq(earthMindRegistryL2.miners(miner1.addr()), true);

        // assert protocol exists
        assertEq(earthMindRegistryL2.protocols(protocol1.addr()), true);

        // assert that the miner has no proposal
        (bytes32 proposalHash,,,) = earthMindConsensusInstance.minerProposals(0, miner1.addr());
        assertEq(proposalHash, bytes32(0x0));

        // assert that the validator has no miner proposals
        // @dev solidity doesn't support returning dynamic arrays inside a struct, hence, the last tuple value is ignored
        (bytes32 topMinersProposalHash,) = earthMindConsensusInstance.validatorProposals(0, validator1.addr());
        assertEq(topMinersProposalHash, bytes32(0x0));
    }

    function test_proposalReceived() public {
        // protocol register first
        _registerProtocolViaMessage(protocol1.addr());

        // request a proposal
        _requestGovernanceDecision();

        // assert that the total epochs are 1
        assertEq(earthMindConsensusInstance.totalEpochs(), 1);

        // assert that the current stage is CommitMiners for epoch 1
        assertEq(uint256(earthMindConsensusInstance.getEpochStage(1)), uint256(TimeBasedEpochs.Stage.CommitMiners));

        EarthMindConsensus.Epoch memory epochResult = earthMindConsensusInstance.getEpoch(1);

        assertEq(epochResult.startTime, block.timestamp);
        assertEq(epochResult.endTime, EPOCH_DURATION + block.timestamp);
        assertEq(epochResult.proposalId, PROPOSAL_ID);
        assertEq(epochResult.sender, protocol1.addr());
    }

    function test_commitProposal_when_minerSubmitsProposal() public {
        // protocol register first
        _registerProtocolViaMessage(protocol1.addr());

        // request a proposal
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        vm.expectEmit(true, true, false, true);

        emit ProposalCommitted(1, miner1.addr(), miner1.getProposalHash());

        miner1.commitProposal();

        (bytes32 proposalHashResult,,,) = earthMindConsensusInstance.minerProposals(1, miner1.addr());

        assertEq(proposalHashResult, miner1.getProposalHash());

        // assert more data
    }

    function test_revealProposal_when_commitPeriodHasntFinished_reverts() public {
        _registerProtocolViaMessage(protocol1.addr());

        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        vm.expectRevert("Not at required stage");

        miner1.revealProposal();
    }

    function test_revealProposal_when_commitPeriodHasFinished() public {
        _registerProtocolViaMessage(protocol1.addr());

        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        vm.expectEmit(true, true, false, true);

        emit ProposalRevealed(1, miner1.addr(), true, "No issues found");

        miner1.revealProposal();
        // assert more data
    }
    // TODO
    // when ProposalNotCommitted
    // when ProposalAlreadyRevealed
    // when wrong stage
    // when not miner
    // when reveal doesnt match
    // assertEvent
    // asset proposal isRevealed = true

    function test_commitScore_when_validatorCommits() public {
        _registerProtocolViaMessage(protocol1.addr());

        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        miner1.revealProposal();

        _increaseTimeBy(MINER_REVEAL_PERIOD);

        address[] memory minerAddresses = new address[](1);
        minerAddresses[0] = miner1.addr();

        validator1.setProposalInfo(PROPOSAL_ID, minerAddresses);

        vm.expectEmit(true, true, false, true);

        emit TopMinersProposalCommitted(1, validator1.addr(), validator1.getProposalHash());

        validator1.commitScores();
    }

    function test_revealScore_when_validatorCommits() public {
        _registerProtocolViaMessage(protocol1.addr());

        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        miner1.revealProposal();

        _increaseTimeBy(MINER_REVEAL_PERIOD);

        address[] memory minerAddresses = new address[](1);
        minerAddresses[0] = miner1.addr();

        validator1.setProposalInfo(PROPOSAL_ID, minerAddresses);

        validator1.commitScores();

        _increaseTimeBy(VALIDATOR_COMMIT_PERIOD);

        vm.expectEmit(true, true, false, true);

        emit TopMinersProposalRevealed(1, validator1.addr(), minerAddresses);

        validator1.revealScores();
    }

    function _requestGovernanceDecision() internal {
        EarthMindConsensus.Request memory request =
            EarthMindConsensus.Request({sender: protocol1.addr(), proposalId: PROPOSAL_ID});

        bytes memory payload = abi.encode(request);

        bytes32 commandId = keccak256(payload);

        vm.prank(protocol1.addr());

        earthMindConsensusInstance.execute(
            commandId, config.sourceChain, Strings.toHexString(protocol1.addr()), payload
        );
    }
}
