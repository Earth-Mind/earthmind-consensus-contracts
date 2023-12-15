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
