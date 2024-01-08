// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EpochEnded} from "./Errors.sol";

contract TimeBasedEpochs {
    uint8 internal constant ZERO = 0;

    struct Epoch {
        uint256 startTime;
    }

    enum Stage {
        NonStarted,
        CommitMiners,
        RevealMiners,
        CommitValidators,
        RevealValidators,
        Ended
    }

    uint256 internal MinerCommitPeriod = 5 minutes;
    uint256 internal MinerRevealPeriod = 5 minutes;
    uint256 internal ValidatorCommitPeriod = 5 minutes;
    uint256 internal ValidatorRevealPeriod = 5 minutes;

    uint256 public totalEpochs;

    mapping(uint256 => Epoch) internal epochs;

    function getEpochStage(uint256 _epoch) public view returns (Stage) {
        uint256 elapsed = block.timestamp - epochs[_epoch].startTime;

        if (epochs[_epoch].startTime == ZERO) {
            return Stage.NonStarted;
        } else if (elapsed < MinerCommitPeriod) {
            return Stage.CommitMiners;
        } else if (elapsed < MinerCommitPeriod + MinerRevealPeriod) {
            return Stage.RevealMiners;
        } else if (elapsed < MinerCommitPeriod + MinerRevealPeriod + ValidatorCommitPeriod) {
            return Stage.CommitValidators;
        } else if (elapsed < MinerCommitPeriod + MinerRevealPeriod + ValidatorCommitPeriod + ValidatorRevealPeriod) {
            return Stage.RevealValidators;
        } else {
            return Stage.Ended;
        }
    }

    modifier atStage(uint256 _epoch, Stage _stage) {
        require(getEpochStage(_epoch) == _stage, "Not at required stage");
        _;
    }

    function getMinerCommitPeriod() external view returns (uint256) {
        return MinerCommitPeriod;
    }

    function getMinerRevealPeriod() external view returns (uint256) {
        return MinerRevealPeriod;
    }

    function getValidatorCommitPeriod() external view returns (uint256) {
        return ValidatorCommitPeriod;
    }

    function getValidatorRevealPeriod() external view returns (uint256) {
        return ValidatorRevealPeriod;
    }

    function getEpoch(uint256 _epoch) external view returns (Epoch memory) {
        return epochs[_epoch];
    }
}
