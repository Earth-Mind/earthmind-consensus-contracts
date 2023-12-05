// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";

contract MockAxelarGasService is IAxelarGasService {
    function payGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForContractCall(
            sender, destinationChain, destinationAddress, keccak256(payload), gasToken, gasFeeAmount, refundAddress
        );
    }

    function payGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string memory symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForContractCallWithToken(
            sender,
            destinationChain,
            destinationAddress,
            keccak256(payload),
            symbol,
            amount,
            gasToken,
            gasFeeAmount,
            refundAddress
        );
    }

    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForContractCall(
            sender, destinationChain, destinationAddress, keccak256(payload), msg.value, refundAddress
        );
    }

    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForContractCallWithToken(
            sender, destinationChain, destinationAddress, keccak256(payload), symbol, amount, msg.value, refundAddress
        );
    }

    function payGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForExpressCall(
            sender, destinationChain, destinationAddress, keccak256(payload), gasToken, gasFeeAmount, refundAddress
        );
    }

    function payGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string memory symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForExpressCallWithToken(
            sender,
            destinationChain,
            destinationAddress,
            keccak256(payload),
            symbol,
            amount,
            gasToken,
            gasFeeAmount,
            refundAddress
        );
    }

    function payNativeGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForExpressCall(
            sender, destinationChain, destinationAddress, keccak256(payload), msg.value, refundAddress
        );
    }

    function payNativeGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForExpressCallWithToken(
            sender, destinationChain, destinationAddress, keccak256(payload), symbol, amount, msg.value, refundAddress
        );
    }

    function addGas(bytes32 txHash, uint256 logIndex, address gasToken, uint256 gasFeeAmount, address refundAddress)
        external
        override
    {
        emit GasAdded(txHash, logIndex, gasToken, gasFeeAmount, refundAddress);
    }

    function addNativeGas(bytes32 txHash, uint256 logIndex, address refundAddress) external payable override {
        emit NativeGasAdded(txHash, logIndex, msg.value, refundAddress);
    }

    function addExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit ExpressGasAdded(txHash, logIndex, gasToken, gasFeeAmount, refundAddress);
    }

    function addNativeExpressGas(bytes32 txHash, uint256 logIndex, address refundAddress) external payable override {
        emit NativeExpressGasAdded(txHash, logIndex, msg.value, refundAddress);
    }

    function collectFees(address payable receiver, address[] calldata tokens, uint256[] calldata amounts) external {}

    function refund(address payable receiver, address token, uint256 amount) external {
        _refund(bytes32(0), 0, receiver, token, amount);
    }

    function refund(bytes32 txHash, uint256 logIndex, address payable receiver, address token, uint256 amount)
        external
    {
        _refund(txHash, logIndex, receiver, token, amount);
    }

    function _refund(bytes32 txHash, uint256 logIndex, address payable receiver, address token, uint256 amount)
        private
    {}

    function contractId() external pure returns (bytes32) {
        return keccak256("axelar-gas-service");
    }

    // upgradeability
    function upgrade(address newImplementation, bytes32 newImplementationCodeHash, bytes calldata params) external {}

    function transferOwnership(address newOwner) external {}

    function setup(bytes calldata data) external {}

    function proposeOwnership(address newOwner) external {}

    function pendingOwner() external view returns (address) {}

    function owner() external view returns (address) {}

    function implementation() external view returns (address) {}

    function acceptOwnership() external {}

    function gasCollector() external returns (address) {}
}
