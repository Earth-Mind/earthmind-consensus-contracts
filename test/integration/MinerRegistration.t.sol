// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {MockGateway} from "@contracts/mocks/MockGateway.sol";
import {AddressUtils} from "@contracts/libraries/AddressUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseIntegrationTest} from "../helpers/BaseIntegrationTest.sol";
import {Miner} from "../helpers/Miner.sol";

import {console2} from "forge-std/console2.sol";

contract MinerRegistrationIntegrationTest is BaseIntegrationTest {
    using AddressUtils for address;

    Miner internal miner1;

    function setUp() public {
        _setUp();

        vm.selectFork(networkL1);

        _setupAccounts();

        miner1 = miners[0];
    }

    function test_MinerRegister() public {
        address minerAddress = miner1.addr();

        miner1.registerMiner{value: 1 ether}();

        bytes32 commandId = keccak256(abi.encodePacked("registerMiner", miner1.addr()));

        _bridgeFromL1ToL2(commandId);

        vm.selectFork(networkL2);

        bool isRegistered = earthMindRegistryL2.miners(minerAddress);

        assertTrue(isRegistered, "Miner is not registered");
    }

    function _bridgeFromL1ToL2(bytes32 _commandId) internal {
        vm.selectFork(networkL1);

        MockGateway.ContractCallParams memory lastcall = mockGatewayL1.getLastContractCall();

        vm.selectFork(networkL2);

        earthMindRegistryL2.execute(
            _commandId, Constants.LOCAL_L1_NETWORK, address(earthMindRegistryL1).toString(), lastcall.payload
        );
    }

    function _bridgeFromL2ToL1(bytes32 _commandId) internal {
        vm.selectFork(networkL2);

        MockGateway.ContractCallParams memory lastcall = mockGatewayL1.getLastContractCall();

        vm.selectFork(networkL1);

        earthMindRegistryL2.execute(
            _commandId, Constants.LOCAL_L2_NETWORK, address(earthMindRegistryL2).toString(), lastcall.payload
        );
    }
}
