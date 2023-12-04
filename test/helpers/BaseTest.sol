// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {Validator} from "../helpers/Validator.sol";
import {Protocol} from "../helpers/Protocol.sol";
import {Miner} from "../helpers/Miner.sol";

contract BaseTest is Test {
    function _increaseTimeBy(uint256 _time) internal {
        vm.warp(block.timestamp + _time);
    }

    function _setNextBlockTimestamp(uint256 _newTimestamp) internal {
        vm.warp(_newTimestamp);
    }

    function _waitBlocks(uint256 _blocks) internal {
        vm.roll(block.number + _blocks);
    }

    function _addressFrom(address _origin, uint256 _nonce) internal pure returns (address) {
        bytes memory data;
        if (_nonce == 0x00) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80));
        } else if (_nonce <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, uint8(_nonce));
        } else if (_nonce <= 0xff) {
            data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), _origin, bytes1(0x81), uint8(_nonce));
        } else if (_nonce <= 0xffff) {
            data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), _origin, bytes1(0x82), uint16(_nonce));
        } else if (_nonce <= 0xffffff) {
            data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), _origin, bytes1(0x83), uint24(_nonce));
        } else {
            data = abi.encodePacked(bytes1(0xda), bytes1(0x94), _origin, bytes1(0x84), uint32(_nonce));
        }
        return address(uint160(uint256(keccak256(data))));
    }
}
