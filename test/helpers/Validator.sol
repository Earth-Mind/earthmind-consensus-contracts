// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Account.sol";

contract Validator is Account {
    constructor(string memory _name, Vm _vm) Account(_name, _vm) {}

    function registerValidator() external {
        vm.prank(addr);
        earthMindRegistryL1Instance.registerValidator();
        _refreshBalances();
    }

    function unRegisterValidator() external {
        vm.prank(addr);
        earthMindRegistryL1Instance.unRegisterValidator();
        _refreshBalances();
    }
}
