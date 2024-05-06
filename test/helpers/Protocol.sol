// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";
import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";

import {BaseAccount} from "./BaseAccount.sol";

// @dev This represents a protocol that aims to register itself to the EarthMindRegistryL1 contract.
contract Protocol is BaseAccount {
    using AddressUtils for address;

    bytes32 internal PROPOSAL_ID = keccak256("proposal_id");

    constructor(BaseAccount.AccountParams memory _params) BaseAccount(_params) {}

    function registerProtocol() external payable {
        vm.startPrank(addr);

        earthMindRegistryL1Instance.registerProtocol{value: msg.value}();

        _refreshBalances();
    }

    function unRegisterProtocol() external payable {
        vm.startPrank(addr);

        earthMindRegistryL1Instance.unRegisterProtocol{value: msg.value}();

        _refreshBalances();
    }

    function requestGovernanceDecision() external payable {
        // TODO FIX
        // EarthMindConsensus.Request memory request = EarthMindConsensus.Request({sender: addr, proposalId: PROPOSAL_ID});

        // bytes memory payload = abi.encode(request);

        // bytes32 commandId = keccak256(payload);

        // vm.startPrank(addr);

        // earthMindConsensusInstance.execute(commandId, config.sourceChain, addr.toString(), payload);

        // _refreshBalances();
    }
}
