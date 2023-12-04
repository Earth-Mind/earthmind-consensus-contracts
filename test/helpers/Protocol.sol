// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Account.sol";

contract Protocol is Account {
    constructor(string memory _name, Vm _vm) Account(_name, _vm) {}

    function registerProtocol() external {
        vm.prank(addr);
        earthMindRegistryL1Instance.registerProtocol();
        _refreshBalances();
    }

    function unRegisterProtocol() external {
        vm.prank(addr);
        earthMindRegistryL1Instance.unRegisterProtocol();
        _refreshBalances();
    }
}
