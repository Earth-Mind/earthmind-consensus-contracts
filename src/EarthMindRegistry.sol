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

    ///////////////////////////////////////////////////////////////////////////
    //  OVERRIDE FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    function _setupData(CrossChainSetup.SetupData setupData) internal view virtual;

    ///////////////////////////////////////////////////////////////////////////
    //  INTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    function _registerProtocol(address _protocol) internal {
        protocols[_protocol] = true;

        emit ProtocolRegistered(_protocol);
    }

    function _unRegisterProtocol(address _protocol) internal {
        protocols[_protocol] = false;

        emit ProtocolUnregistered(_protocol);
    }

    function _registerMiner(address _miner) internal {
        miners[_miner] = true;

        emit MinerRegistered(_miner);
    }

    function _unRegisterMiner(address _miner) internal {
        miners[_miner] = false;

        emit MinerUnregistered(_miner);
    }

    function _registerValidator(address _validator) internal {
        validators[_validator] = true;

        emit ValidatorRegistered(_validator);
    }

    function _unRegisterValidator(address _validator) internal {
        validators[_validator] = false;

        emit ValidatorUnregistered(_validator);
    }
}
