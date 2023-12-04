// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Account.sol";

contract Miner is Account {
    constructor(string memory _name, Vm _vm) Account(_name, _vm) {}

    function registerMiner() external {
        vm.prank(addr);
        earthMindRegistryL1Instance.registerMiner();
        _refreshBalances();
    }

    function unRegisterMiner() external {
        vm.prank(addr);
        earthMindRegistryL1Instance.unRegisterMiner();
        _refreshBalances();
    }
}
