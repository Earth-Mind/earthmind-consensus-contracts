// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EpochEnded} from "./Errors.sol";

contract TimeBasedEpochs {
    struct Epoch {
        uint256 startTime;
    }

    enum Stage {
        CommitMiners,
        RevealMiners,
        CommitValidators,
        RevealValidators
    }

    uint256 internal MinerCommitPeriod = 5 minutes;
    uint256 internal MinerRevealPeriod = 5 minutes;
    uint256 internal ValidatorCommitPeriod = 5 minutes;
    uint256 internal ValidatorRevealPeriod = 5 minutes;

    uint256 public currentEpoch;

    mapping(uint256 => Epoch) public epochs;

    function getCurrentStage() public view returns (Stage) {
        uint256 elapsed = block.timestamp - epochs[currentEpoch].startTime;

        if (elapsed < MinerCommitPeriod) {
            return Stage.CommitMiners;
        } else if (elapsed < MinerCommitPeriod + MinerRevealPeriod) {
            return Stage.RevealMiners;
        } else if (elapsed < MinerCommitPeriod + MinerRevealPeriod + ValidatorCommitPeriod) {
            return Stage.CommitValidators;
        } else if (elapsed < MinerCommitPeriod + MinerRevealPeriod + ValidatorCommitPeriod + ValidatorRevealPeriod) {
            return Stage.RevealValidators;
        } else {
            revert EpochEnded();
        }
    }

    modifier atStage(Stage _stage) {
        require(getCurrentStage() == _stage, "Not at required stage");
        _;
    }
}
