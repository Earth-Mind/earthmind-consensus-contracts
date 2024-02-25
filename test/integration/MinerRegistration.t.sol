// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {MockGateway} from "@contracts/mocks/MockGateway.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {BaseIntegrationTest} from "../helpers/BaseIntegrationTest.sol";

import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract MinerRegistrationIntegrationTest is BaseIntegrationTest {
    using DeploymentUtils for Vm;

    MockGateway internal mockGateway;

    string public constant NETWORK_L1 = "31337";
    string public constant NETWORK_L2 = "31338";

    uint256 networkL1;
    uint256 networkL2;

    function setUp() public {
        networkL1 = vm.createFork("http://localhost:8555");
        networkL2 = vm.createFork("http://localhost:8556");

        address gatewayAddress = vm.loadDeploymentAddress(NETWORK_L1, "MockGateway");
        mockGateway = MockGateway(gatewayAddress);
    }

    function test_MinerRegister() public {
        vm.selectFork(networkL1);

        bool otherResult = mockGateway.validateContractCall(bytes32(0), "", "", bytes32(0));

        assertEq(otherResult, true);

        // miner1.registerMiner{value: 1 ether}();

        // assertEq(earthMindRegistryL1.miners(miner1.addr()), true);
    }
}

// corro cross-anvil
// obtengo las direcciones
// creo instancias
// hago llamadas
// bridgeo
// aserto

// slot 12 seconds
// epoch = 32 slots
// delays increase the cost of the attack if someone gets a lot of stake
// validator has to collude with a miner
//
// hacerlo de una forma que cuando quiera salir, trigeree algo en L2
// y luego en L1 ya debe de poner hacer su withdraw pero esta limitado
// al tiempo de exiting.

// subnet fee
// 1100 TAO
// 600k

// Accumulate a lot of TAO stake
// Technical part...

// Validator and Miner to be running our thing
// What the stake weight of these groups...

// graph of stake weight
// bridge between our protocol and Bittensor

// 1. Bridge
// 2. Lending market for the subnet token
// 3. EarthMind subnet

// Near account will control a Bittensor account
//
// What is the validator weight for the decisions...
//
// 1. Validator weight (TAO stakeweight)
//
// el protocol es una subnet...
// people are calling our smart contract in L2...
// and we are able to bridge the stake weights...
// check reward mechanism....
// we make the subnet operating the protocol....
//
//
// they will get TAO rewards
//
//
// Research subnet thing
//
// Subnet 0...
// Subnet 1...gets 80% rewards of the TAO emissions

// How do we replicate that state? That's a bridge problem.....
// 2 ways:
//  Liquid Staking Token
//  Message passing
//
// Without smart contracts.....we can't do it
// Light client that goes from Bittensor to NEAR
//
