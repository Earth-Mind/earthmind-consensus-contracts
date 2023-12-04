// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Account.sol";

contract Validator is Account {
    constructor(string memory _name, Vm _vm) Account(_name, _vm) {}

    function registerValidator() external payable {
        vm.prank(addr);
        earthMindRegistryL1Instance.registerValidator{value: msg.value}();
        _refreshBalances();
    }

    function unRegisterValidator() external payable {
        vm.prank(addr);
        earthMindRegistryL1Instance.unRegisterValidator{value: msg.value}();
        _refreshBalances();
    }

    // commit scores
    // reveal scores
}
