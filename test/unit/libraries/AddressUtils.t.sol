// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";

contract AddressUtilsTest is Test {
    function test_valid_string() public {
        address validAddressStr = 0x1234567890AbcdEF1234567890aBcdef12345678;
        string memory expectedAddress = "0x1234567890abcdef1234567890abcdef12345678";

        string memory result = AddressUtils.toString(validAddressStr);
        assertEq(result, expectedAddress, "The converted address does not match the expected address.");
    }
}
