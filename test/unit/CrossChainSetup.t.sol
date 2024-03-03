// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";

import {CrossChainSetup} from "@contracts/CrossChainSetup.sol";
import {CrossChainSetupHasBeenInitialised} from "@contracts/Errors.sol";

contract CrossChainSetupTest is Test {
    address deployer = vm.addr(1234);

    CrossChainSetup internal crossChainSetupInstance;

    function setUp() public {
        vm.prank(deployer);
        crossChainSetupInstance = new CrossChainSetup(deployer);
    }

    function test_initialProperties() public {
        assertEq(crossChainSetupInstance.initialised(), false);
        assertEq(crossChainSetupInstance.owner(), deployer);

        CrossChainSetup.SetupData memory setupData = crossChainSetupInstance.getSetupData();
        assertEq(setupData.sourceChain, "");
        assertEq(setupData.destinationChain, "");
        assertEq(setupData.registryL1, address(0));
        assertEq(setupData.registryL2, address(0));
    }

    function test_setup() public {
        address registryL1 = vm.addr(2345);
        address registryL2 = vm.addr(3456);
        string memory sourceChain = "sourceChain";
        string memory destinationChain = "destinationChain";

        vm.startPrank(deployer);

        crossChainSetupInstance.setup(
            CrossChainSetup.SetupData({
                sourceChain: sourceChain,
                destinationChain: destinationChain,
                registryL1: registryL1,
                registryL2: registryL2
            })
        );

        assertEq(crossChainSetupInstance.initialised(), true);

        CrossChainSetup.SetupData memory setupData = crossChainSetupInstance.getSetupData();
        assertEq(setupData.sourceChain, sourceChain);
        assertEq(setupData.destinationChain, destinationChain);
        assertEq(setupData.registryL1, registryL1);
        assertEq(setupData.registryL2, registryL2);
    }

    function test_setup_when_initialised_reverts() public {
        address registryL1 = vm.addr(2345);
        address registryL2 = vm.addr(3456);
        string memory sourceChain = "sourceChain";
        string memory destinationChain = "destinationChain";

        vm.startPrank(deployer);

        crossChainSetupInstance.setup(
            CrossChainSetup.SetupData({
                sourceChain: sourceChain,
                destinationChain: destinationChain,
                registryL1: registryL1,
                registryL2: registryL2
            })
        );

        vm.expectRevert(CrossChainSetupHasBeenInitialised.selector);

        crossChainSetupInstance.setup(
            CrossChainSetup.SetupData({
                sourceChain: sourceChain,
                destinationChain: destinationChain,
                registryL1: registryL1,
                registryL2: registryL2
            })
        );
    }

    function test_setup_when_non_owner_reverts() public {
        address registryL1 = vm.addr(2345);
        address registryL2 = vm.addr(3456);
        string memory sourceChain = "sourceChain";
        string memory destinationChain = "destinationChain";

        vm.expectRevert("Ownable: caller is not the owner");

        crossChainSetupInstance.setup(
            CrossChainSetup.SetupData({
                sourceChain: sourceChain,
                destinationChain: destinationChain,
                registryL1: registryL1,
                registryL2: registryL2
            })
        );
    }
}
