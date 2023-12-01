// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IEarthMindRegistry {
    event ProtocolRegistered(address indexed protocol);

    event ProtocolUnregistered(address indexed protocol);

    event MinerRegistered(address indexed Miner);

    event MinerUnregistered(address indexed Miner);

    event ValidatorRegistered(address indexed Validator);

    event ValidatorUnregistered(address indexed Validator);
}
