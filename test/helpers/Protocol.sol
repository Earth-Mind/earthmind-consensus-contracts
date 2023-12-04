// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Account.sol";

contract Protocol is Account {
    constructor(string memory _name, Vm _vm) Account(_name, _vm) {}

    function registerProtocol() external payable {
        vm.prank(addr);

        earthMindRegistryL1Instance.registerProtocol{value: msg.value}();

        _refreshBalances();
    }

    function unRegisterProtocol() external payable {
        vm.prank(addr);

        earthMindRegistryL1Instance.unRegisterProtocol{value: msg.value}();

        _refreshBalances();
    }
}
