// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@contracts/utils/Create2Deployer.sol";

contract Create2DeployerTest is Test {
    Create2Deployer deployerInstance;

    address deployer = vm.addr(1234);

    function setUp() public {
        vm.prank(deployer);
        vm.deal(deployer, 100 ether);
        deployerInstance = new Create2Deployer();
    }

    function test_deploy_when_insufficient_balance_reverts() public {
        bytes memory bytecode = type(SimpleContract).creationCode;
        bytes32 salt = keccak256("test-salt");
        uint256 amount = 1 ether;
        uint256 sentValue = 0.01 ether;

        bytes memory expectedErrorData = abi.encodeWithSelector(
            Create2Deployer.Create2InsufficientBalance.selector,
            sentValue, // received
            amount // minimumNeeded
        );

        vm.startPrank(deployer);

        vm.expectRevert(expectedErrorData);

        deployerInstance.deploy{value: sentValue}(amount, salt, bytecode);
    }

    function test_deploy_when_empty_bytecode_reverts() public {
        bytes memory bytecode = "";
        bytes32 salt = keccak256("test-salt");
        uint256 amount = 0;

        vm.startPrank(deployer);

        vm.expectRevert(Create2Deployer.Create2EmptyBytecode.selector);

        deployerInstance.deploy{value: amount}(amount, salt, bytecode);
    }

    function test_deploy_when_valid_bytecode() public {
        uint256 constructorArguments = 100;
        bytes memory bytecode = abi.encodePacked(type(SimpleContract).creationCode, constructorArguments);

        bytes32 salt = keccak256("test-salt");
        uint256 amount = 0;

        vm.startPrank(deployer);

        address addr = deployerInstance.deploy{value: amount}(amount, salt, bytecode);

        assertTrue(addr != address(0));
    }

    function test_deploy_when_fails_reverts() public {
        uint256 constructorArguments = 100;
        bytes memory bytecode = abi.encodePacked(type(SimpleContract).creationCode, constructorArguments);

        bytes32 salt = keccak256("test-salt");
        uint256 amount = 1;

        vm.startPrank(deployer);

        vm.expectRevert(Create2Deployer.Create2FailedDeployment.selector);
        address addr = deployerInstance.deploy{value: amount}(amount, salt, bytecode);

        assertTrue(addr == address(0));
    }

    function test_computeAddress() public {
        uint256 constructorArguments = 100;
        bytes memory bytecode = abi.encodePacked(type(SimpleContract).creationCode, constructorArguments);

        bytes32 bytecodeHash = keccak256(bytecode);

        bytes32 salt = keccak256("test-salt");
        uint256 amount = 0;

        vm.startPrank(deployer);

        address deployedAddr = deployerInstance.deploy{value: amount}(amount, salt, bytecode);
        address computedAddr = deployerInstance.computeAddress(salt, bytecodeHash);

        assertEq(deployedAddr, computedAddr);
    }
}

contract SimpleContract {
    uint256 public value;

    constructor(uint256 _value) {
        value = _value;
    }
}
