// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Account.sol";

// @dev This represents a protocol that aims to register itself to the EarthMindRegistryL1 contract.
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

    function requestGovernanceDecision() external payable {
        vm.prank(addr);

        // TODO: Implement requesting a governance decision

        _refreshBalances();
    }
}
