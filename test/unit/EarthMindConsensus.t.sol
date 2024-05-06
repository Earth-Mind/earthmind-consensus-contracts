// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";
import {IAxelarGateway} from "@axelar/interfaces/IAxelarGateway.sol";

import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";
import {TimeBasedEpochs} from "@contracts/TimeBasedEpochs.sol";
import {Configuration} from "@config/Configuration.sol";
import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";

import {
    ProposalAlreadyCommitted,
    ProposalAlreadyRevealed,
    ProposalNotCommitted,
    InvalidProposal,
    InvalidMiner,
    InvalidValidator,
    TopMinerProposalAlreadyCommitted,
    TopMinerProposalAlreadyRevealed,
    TopMinerProposalNotCommitted,
    InvalidTopMinerProposal,
    InvalidSourceChain,
    InvalidSourceAddress
} from "@contracts/Errors.sol";

import {BaseConsensusTest} from "../helpers/BaseConsensusTest.sol";

contract EarthMindConsensusTest is BaseConsensusTest {
    using AddressUtils for address;

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

    // Miners tests
    function test_commitProposal() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        vm.expectEmit(true, true, false, true);

        emit ProposalCommitted(1, miner1.addr(), miner1.getProposalHash());

        miner1.commitProposal();

        (bytes32 proposalHashResult,,,) = earthMindConsensusInstance.minerProposals(1, miner1.addr());

        assertEq(proposalHashResult, miner1.getProposalHash());

        // assert more data
    }

    function test_commitProposal_when_alreadyCommitted_reverts() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        bytes memory bytesError = abi.encodeWithSelector(ProposalAlreadyCommitted.selector, miner1.addr());

        vm.expectRevert(bytesError);

        miner1.commitProposal();
    }

    function test_commitProposal_when_sender_is_not_miner_reverts() public {
        uint256 epochId = 1;

        _requestGovernanceDecision();

        bytes memory bytesError = abi.encodeWithSelector(InvalidMiner.selector, DEPLOYER);

        vm.expectRevert(bytesError);

        vm.startPrank(DEPLOYER);

        earthMindConsensusInstance.commitProposal(epochId, bytes32(0x0));
    }

    function test_revealProposal_when_commitPeriod_hasnt_finished_reverts() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        vm.expectRevert("Not at required stage");

        miner1.revealProposal();
    }

    function test_revealProposal_when_commitPeriod_has_finished() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        vm.expectEmit(true, true, false, true);

        emit ProposalRevealed(1, miner1.addr(), true, "No issues found");

        miner1.revealProposal();
    }

    function test_revealProposal_when_has_been_revealed_reverts() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        miner1.revealProposal();

        bytes memory bytesError = abi.encodeWithSelector(ProposalAlreadyRevealed.selector, miner1.addr());

        vm.expectRevert(bytesError);

        miner1.revealProposal();
    }

    function test_revealProposal_when_not_commited_before_reverts() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        bytes memory bytesError = abi.encodeWithSelector(ProposalNotCommitted.selector, miner1.addr());

        vm.expectRevert(bytesError);

        miner1.revealProposal();
    }

    function test_revealProposal_when_hashes_dont_match_reverts() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        miner1.setProposalInfo(PROPOSAL_ID, false, "No issues found and more");

        bytes memory bytesError = abi.encodeWithSelector(InvalidProposal.selector, miner1.addr());

        vm.expectRevert(bytesError);

        miner1.revealProposal();
    }

    // Validators tests
    function test_commitScore() public {
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

    function test_commitScore_when_validator_not_registered_reverts() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        miner1.revealProposal();

        _increaseTimeBy(MINER_REVEAL_PERIOD);

        uint256 epochId = 2;

        bytes memory bytesError = abi.encodeWithSelector(InvalidValidator.selector, DEPLOYER);

        vm.expectRevert(bytesError);

        vm.startPrank(DEPLOYER);

        earthMindConsensusInstance.commitScores(epochId, bytes32(0x0));
    }

    function test_commitScore_when_already_committed_reverts() public {
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

        bytes memory bytesError = abi.encodeWithSelector(TopMinerProposalAlreadyCommitted.selector, validator1.addr());

        vm.expectRevert(bytesError);

        validator1.commitScores();
    }

    function test_revealScore() public {
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

    function test_revealScore_when_already_revealed_reverts() public {
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

        validator1.revealScores();

        bytes memory bytesError = abi.encodeWithSelector(TopMinerProposalAlreadyRevealed.selector, validator1.addr());

        vm.expectRevert(bytesError);

        validator1.revealScores();
    }

    function test_revealScore_when_not_committed_reverts() public {
        _requestGovernanceDecision();

        miner1.setProposalInfo(PROPOSAL_ID, true, "No issues found");

        miner1.commitProposal();

        _increaseTimeBy(MINER_COMMIT_PERIOD);

        miner1.revealProposal();

        _increaseTimeBy(MINER_REVEAL_PERIOD);

        address[] memory minerAddresses = new address[](1);
        minerAddresses[0] = miner1.addr();

        validator1.setProposalInfo(PROPOSAL_ID, minerAddresses);

        _increaseTimeBy(VALIDATOR_COMMIT_PERIOD);

        bytes memory bytesError = abi.encodeWithSelector(TopMinerProposalNotCommitted.selector, validator1.addr());

        vm.expectRevert(bytesError);

        validator1.revealScores();
    }

    function test_revealScore_when_hashes_dont_match_reverts() public {
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

        address[] memory minerAddresses2 = new address[](1);
        minerAddresses[0] = validator1.addr(); // @dev we set a different address so the hash changes

        validator1.setProposalInfo(PROPOSAL_ID, minerAddresses2);

        bytes memory bytesError = abi.encodeWithSelector(InvalidTopMinerProposal.selector, validator1.addr());

        vm.expectRevert(bytesError);

        validator1.revealScores();
    }

    // Execute tests

    function test_execute_with_invalid_source_address_reverts() public {
        EarthMindConsensus.Request memory request =
            EarthMindConsensus.Request({sender: protocol1.addr(), proposalId: PROPOSAL_ID});

        bytes memory payload = abi.encode(request);

        bytes32 commandId = keccak256(payload);
        string memory sourceAddress = miner1.addr().toString();

        vm.startPrank(protocol1.addr());

        vm.expectRevert(InvalidSourceAddress.selector);

        earthMindConsensusInstance.execute(commandId, config.sourceChain, sourceAddress, payload);
    }

    function test_execute_with_invalid_source_chain_reverts() public {
        EarthMindConsensus.Request memory request =
            EarthMindConsensus.Request({sender: protocol1.addr(), proposalId: PROPOSAL_ID});

        bytes memory payload = abi.encode(request);

        bytes32 commandId = keccak256(payload);
        string memory sourceAddress = protocol1.addr().toString();
        string memory wrongSourceChain = "2";
        vm.startPrank(protocol1.addr());

        vm.expectRevert(InvalidSourceChain.selector);

        earthMindConsensusInstance.execute(commandId, wrongSourceChain, sourceAddress, payload);
    }

    // Helper functions
    function _requestGovernanceDecision() internal {
        protocol1.requestGovernanceDecision();
    }
}
