// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/executable/AxelarExecutable.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/interfaces/IAxelarGasService.sol";

import {CrossChainSetup} from "./CrossChainSetup.sol";

import {NoGasPaymentProvided} from "./Errors.sol";

abstract contract EarthMindRegistry is AxelarExecutable {
    IAxelarGasService public immutable gasReceiver;

    string public DESTINATION_CHAIN;
    string public DESTINATION_ADDRESS;

    mapping(address protocol => bool isRegistered) public protocols;
    mapping(address miner => bool isRegistered) public miners;
    mapping(address validator => bool isRegistered) public validators;

    event ProtocolRegistered(address indexed protocol);
    event ProtocolUnregistered(address indexed protocol);
    event MinerRegistered(address indexed Miner);
    event MinerUnregistered(address indexed Miner);
    event ValidatorRegistered(address indexed Validator);
    event ValidatorUnregistered(address indexed Validator);
    // event ContractCallSent(string destinationChain, string contractAddress, bytes payload, address sender);

    constructor(CrossChainSetup.SetupData _setup, address _gateway, address _gasService) AxelarExecutable(_gateway) {
        gasReceiver = IAxelarGasService(_gasService);

        CrossChainSetup.SetupData setupData = _setup.getSetupData();
        _setupData(setupData);
    }

    function _setupData(CrossChainSetup.SetupData setupData) internal view virtual {
        DESTINATION_CHAIN = setupData.destinationChain;
        DESTINATION_ADDRESS = setupData.registryL2;
    }
    ///////////////////////////////////////////////////////////////////////////
    //  EXTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    function registerProtocol() external {
        _validateProtocolRegistration(msg.sender);

        protocols[msg.sender] = true;

        emit ProtocolRegistered(msg.sender);
    }

    function unRegisterProtocol() external {
        _validateProtocolUnRegistration(msg.sender);

        protocols[msg.sender] = false;

        emit ProtocolUnregistered(msg.sender);
    }

    function registerMiner() external {
        _validateMinerRegistration(msg.sender);

        miners[msg.sender] = true;

        emit MinerRegistered(msg.sender);
    }

    function unRegisterMiner() external {
        _validateMinerUnRegistration(msg.sender);

        miners[msg.sender] = false;

        emit MinerUnregistered(msg.sender);
    }

    function registerValidator() external {
        _validateValidatorRegistration(msg.sender);

        validators[msg.sender] = true;

        emit ValidatorRegistered(msg.sender);
    }

    function unRegisterValidator() external {
        _validateValidatorUnRegistration(msg.sender);

        validators[msg.sender] = false;

        emit ValidatorUnregistered(msg.sender);
    }

    ///////////////////////////////////////////////////////////////////////////
    //  INTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////
    function _validateProtocolRegistration(address protocol) internal view {
        require(!protocols[protocol], "Protocol already registered");

        // TODO: implement logic
    }

    function _validateProtocolUnRegistration(address protocol) internal view {
        require(protocols[protocol], "Protocol not registered");

        // TODO: implement logic
    }

    function _validateMinerRegistration(address miner) internal view {
        require(!miners[miner], "Miner already registered");

        // TODO: implement logic
    }

    function _validateMinerUnRegistration(address miner) internal view {
        require(miners[miner], "Miner no registered");

        // TODO: implement logic
    }

    function _validateValidatorRegistration(address validator) internal view {
        require(!validators[validator], "Validator already registered");

        // TODO: implement logic
    }

    function _validateValidatorUnRegistration(address validator) internal view {
        require(validators[validator], "Validator not registered");

        // TODO: implement logic
    }

    // function sendMessage(bytes memory _payload) internal {
    //     if (msg.value == 0) {
    //         revert NoGasPaymentProvided();
    //     }

    //     gasReceiver.payNativeGasForContractCall{value: msg.value}(
    //         address(this), DESTINATION_CHAIN, DESTINATION_ADDRESS, _payload, msg.sender
    //     );

    //     gateway.callContract(DESTINATION_CHAIN, DESTINATION_ADDRESS, _payload);

    //     emit ContractCallSent(DESTINATION_CHAIN, DESTINATION_ADDRESS, _payload, msg.sender);
    // }
}