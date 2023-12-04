//SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

import {EarthMindToken} from "@contracts/EarthMindToken.sol";
import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";

import "forge-std/Vm.sol";

contract Account {
    address public immutable addr;

    EarthMindToken internal earthMindTokenInstance;
    EarthMindRegistryL1 internal earthMindRegistryL1Instance;

    uint256 public initialTokenBalance;
    uint256 public currentTokenBalance;

    uint256 public initialETHBalance;
    uint256 public currentETHBalance;

    Vm internal vm;
    bool internal initialized;

    constructor(string memory _name, Vm _vm) {
        vm = _vm;
        addr = _createAccount(_name);
        initialized = false;
    }

    function init(
        EarthMindRegistryL1 _earthMindRegistryL1Instance,
        EarthMindToken _earthMindTokenInstance,
        address _deployer
    ) public {
        require(!initialized, "Account already initialized");
        initialized = true;

        // Send some tokens to the account
        vm.startPrank(_deployer);
        _earthMindTokenInstance.transfer(addr, 50_000 ether);
        vm.stopPrank();

        // Approve permissions to registry contract
        vm.startPrank(addr);
        _earthMindTokenInstance.approve(address(_earthMindRegistryL1Instance), 20_000 ether);
        vm.stopPrank();

        // Set initial balances
        initialETHBalance = address(addr).balance;
        initialTokenBalance = _earthMindTokenInstance.balanceOf(addr);

        // Set instances
        earthMindTokenInstance = _earthMindTokenInstance;
        earthMindRegistryL1Instance = _earthMindRegistryL1Instance;
    }

    function refreshBalances() public {
        _refreshBalances();
    }

    function _refreshBalances() internal {
        currentTokenBalance = earthMindTokenInstance.balanceOf(addr);
        currentETHBalance = address(addr).balance;
    }

    function _createAccount(string memory _name) internal returns (address) {
        uint256 privateKey = uint256(keccak256(abi.encodePacked(_name)));
        address result = vm.addr(privateKey);
        vm.label(result, _name);
        vm.deal(result, 1000 ether);
        return result;
    }
}
