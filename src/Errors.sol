// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

error NoGasPaymentProvided();

error CrossChainSetupHasBeenInitialised();

error InvalidSourceAddress();

error InvalidSourceChain();

error ProtocolAlreadyRegistered(address protocol);

error ProtocolNotRegistered(address protocol);

error ValidatorAlreadyRegistered(address miner);

error ValidatorNotRegistered(address miner);

error MinerAlreadyRegistered(address miner);

error MinerNotRegistered(address miner);

error InvalidValidator(address validator);

error InvalidMiner(address miner);

error InvalidProposal(address miner);

error InvalidTopMinerProposal(address validator);

error ProposalAlreadyCommitted(address miner);

error ProposalAlreadyRevealed(address miner);

error ProposalNotCommitted(address miner);

error TopMinerProposalAlreadyCommitted(address validator);

error TopMinerProposalAlreadyRevealed(address validator);

error TopMinerProposalNotCommitted(address validator);

error EpochEnded();
