//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

import {Vm} from "forge-std/Vm.sol";

contract BaseAccount {
    address public immutable addr;

    EarthMindRegistryL1 internal earthMindRegistryL1Instance;
    EarthMindRegistryL2 internal earthMindRegistryL2Instance;
    EarthMindConsensus internal earthMindConsensusInstance;

    uint256 public initialRewardsBalance;
    uint256 public currentRewardsBalance;

    uint256 public initialETHBalance;
    uint256 public currentETHBalance;

    Vm internal vm;

    bool internal forkMode;
    uint256 internal networkL1;
    uint256 internal networkL2;

    struct AccountParams {
        string name;
        Vm vm;
        bool forkMode;
        uint256 l1Network;
        uint256 l2Network;
        EarthMindRegistryL1 earthMindRegistryL1Instance;
        EarthMindRegistryL2 earthMindRegistryL2Instance;
        EarthMindConsensus earthMindConsensusInstance;
    }

    constructor(AccountParams memory _params) {
        vm = _params.vm;
        addr = _createAccount(_params.name);

        forkMode = _params.forkMode;
        networkL1 = _params.l1Network;
        networkL2 = _params.l2Network;

        // Set instances
        earthMindRegistryL1Instance = _params.earthMindRegistryL1Instance;
        earthMindRegistryL2Instance = _params.earthMindRegistryL2Instance;
        earthMindConsensusInstance = _params.earthMindConsensusInstance;

        // Set initial balances
        initialETHBalance = address(addr).balance;
        initialRewardsBalance = 0;
    }

    function refreshBalances() public {
        _refreshBalances();
    }

    function _refreshBalances() internal {
        if (forkMode) {
            vm.selectFork(networkL2);
        }

        currentETHBalance = address(addr).balance;

        if (address(earthMindConsensusInstance) != address(0)) {
            currentRewardsBalance = earthMindConsensusInstance.rewardsBalance(addr);
        }
    }

    function _createAccount(string memory _name) internal returns (address) {
        uint256 privateKey = uint256(keccak256(abi.encodePacked(_name)));
        address result = vm.addr(privateKey);
        vm.label(result, _name);
        vm.deal(result, 1000 ether);
        return result;
    }
}
