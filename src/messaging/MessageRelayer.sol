//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AxelarExecutable} from "@axelar/executable/AxelarExecutable.sol";
import {IAxelarGasService} from "@axelar/interfaces/IAxelarGasService.sol";

import {IEarthMindRegistry} from "../interfaces/IEarthMindRegistry.sol";
import {ProtocolNotWhitelisted, NoGasPaymentProvided} from "../Errors.sol";

contract MessageRelayer is AxelarExecutable {
    IAxelarGasService public immutable gasReceiver;
    IEarthMindRegistry public immutable registry;

    event MessageSent(address indexed sender, string destinationChain, string destinationAddress, bytes payload);

    constructor(address _registry, address _gateway, address _gasReceiver) AxelarExecutable(_gateway) {
        gasReceiver = IAxelarGasService(_gasReceiver);
        registry = IEarthMindRegistry(_registry);
    }

    function sendMessage(string memory _destinationChain, string memory _destinationAddress, bytes memory _payload)
        external
        payable
        onlyWhitelistedProtocols
    {
        if (msg.value == 0) {
            revert NoGasPaymentProvided();
        }

        gasReceiver.payNativeGasForContractCall{value: msg.value}(
            address(this), _destinationChain, _destinationAddress, _payload, msg.sender
        );

        gateway.callContract(_destinationChain, _destinationAddress, _payload);

        emit MessageSent(msg.sender, _destinationChain, _destinationAddress, _payload);
    }

    modifier onlyWhitelistedProtocols() {
        if (!registry.protocols(msg.sender)) {
            revert ProtocolNotWhitelisted();
        }
        _;
    }
}
