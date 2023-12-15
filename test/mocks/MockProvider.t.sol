// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {MockProvider} from "@contracts/mocks/MockProvider.sol";

import "forge-std/Test.sol";

contract MockProviderTest is Test {
    MockProvider instance;

    function setUp() public {
        instance = new MockProvider();
    }

    function test_when() public {
        instance.when(bytes4(0x12345678));

        assertEq(instance.lastFunctionSignature(), bytes4(0x12345678));
    }

    function test_thenReturns() public {
        instance.when(bytes4(0x12345678)).thenReturns("0x12345678");

        assertTrue(instance.mockConfigurationExists(bytes4(0x12345678)));
        assertEq(instance.mockConfigurations(bytes4(0x12345678)), "0x12345678");

        assertEq(instance.lastFunctionSignature(), bytes4(0));
    }

    function test_thenReturns_whenNoFunctionSignature_reverts() public {
        vm.expectRevert("MockProvider: No function signature specified");

        instance.thenReturns("0x12345678");
    }

    function test_fallback() public {
        instance.when(bytes4(0x12345678)).thenReturns("0x12345678");

        (bool success, bytes memory data) = address(instance).call(abi.encodeWithSelector(bytes4(0x12345678)));

        assertTrue(success);
        assertEq(data, "0x12345678");
    }

    function test_fallback_whenNoConfiguration_reverts() public {
        vm.expectRevert("MockProvider: No configuration found for the given function signature");

        (bool revertsAsExpected, bytes memory data) = address(instance).call(abi.encodeWithSelector(bytes4(0x12345678)));

        assertTrue(revertsAsExpected, "expectRevert: call did not revert");
    }

    function test_receive_reverts() public {
        vm.expectRevert("MockProvider: receive() not allowed");

        (bool revertsAsExpected,) = address(instance).call{value: 1 ether}("");

        assertTrue(revertsAsExpected, "expectRevert: call did not revert");
    }
}
