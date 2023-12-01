//SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

enum MessageType {
    PROTOCOL_REGISTERED,
    PROTOCOL_UNREGISTERED,
    VALIDATOR_REGISTERED,
    VALIDATOR_UNREGISTERED,
    MINER_REGISTERED,
    MINER_UNREGISTERED
}

struct RegistryMessage {
    MessageType messageType;
    address sender;
    address registryAddress;
    bytes messagePayload;
}

struct DepositMessagePayload {
    string stableAssetSymbol;
    uint256 amount;
}

struct BorrowMessagePayload {
    string collateralAssetSymbol;
    uint256 loanAmount;
    uint256 collateralAmount;
    uint256 loanTerm;
}
