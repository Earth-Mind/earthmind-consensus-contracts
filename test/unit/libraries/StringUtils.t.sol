// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";

import "@contracts/libraries/StringUtils.sol";

contract StringUtilsTest is Test {
    function test_valid_address() public {
        string memory validAddressStr = "0x1234567890AbCdEf1234567890abcdef12345678";
        address expectedAddress = 0x1234567890AbcdEF1234567890aBcdef12345678;

        address result = StringUtils.stringToAddress(validAddressStr);
        assertEq(result, expectedAddress, "The converted address does not match the expected address.");
    }

    function test_when_invalid_length_reverts() public {
        string memory invalidLengthStr = "0x123";

        vm.expectRevert("Invalid address length");

        StringUtils.stringToAddress(invalidLengthStr);
    }

    function test_when_invalid_character_reverts() public {
        string memory invalidCharStr = "0x1234567890AbCdEf1234567890Gbcdef12345678";

        vm.expectRevert("Invalid character in address");

        StringUtils.stringToAddress(invalidCharStr);
    }
}
