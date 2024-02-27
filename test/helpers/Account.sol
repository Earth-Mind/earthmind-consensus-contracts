//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindRegistryL1} from "@contracts/EarthMindRegistryL1.sol";
import {EarthMindRegistryL2} from "@contracts/EarthMindRegistryL2.sol";
import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

import "forge-std/Vm.sol";
import "forge-std/console.sol";

contract Account {
    address public immutable addr;

    EarthMindRegistryL1 internal earthMindRegistryL1Instance;
    EarthMindRegistryL2 internal earthMindRegistryL2Instance;
    EarthMindConsensus internal earthMindConsensusInstance;

    uint256 public initialRewardsBalance;
    uint256 public currentRewardsBalance;

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
        EarthMindRegistryL2 _earthMindRegistryL2Instance,
        EarthMindConsensus _earthMindConsensusInstance
    ) public {
        require(!initialized, "Account already initialized");
        initialized = true;
        console.log("Initializing Account");
        // Set instances
        earthMindRegistryL1Instance = _earthMindRegistryL1Instance;
        earthMindRegistryL2Instance = _earthMindRegistryL2Instance;
        earthMindConsensusInstance = _earthMindConsensusInstance;

        // Set initial balances
        initialETHBalance = address(addr).balance;

        if (address(earthMindConsensusInstance) != address(0)) {
            initialRewardsBalance = earthMindConsensusInstance.rewardsBalance(addr);
        }

        console.log("Account initialized");
    }

    function refreshBalances() public {
        _refreshBalances();
    }

    function _refreshBalances() internal {
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
