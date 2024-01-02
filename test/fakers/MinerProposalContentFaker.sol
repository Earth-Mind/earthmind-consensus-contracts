// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindConsensus} from "@contracts/EarthMindConsensus.sol";

library Utils {
    function hashMinerProposal(address _miner, bool _vote, string memory _message) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_miner, _vote, _message));
    }

    function hashValidatorProposal(address _validator, address[] memory _miners) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_validator, _miners));
    }
}

library MinerProposalFaker {
    function init(address _miner, bool _vote, string memory _message)
        internal
        pure
        returns (EarthMindConsensus.MinerProposal memory)
    {
        return EarthMindConsensus.MinerProposal({
            proposalHash: Utils.hashMinerProposal(_miner, _vote, _message),
            isRevealed: false,
            vote: _vote,
            message: _message
        });
    }

    function withVote(EarthMindConsensus.MinerProposal memory _params, bool _vote)
        internal
        pure
        returns (EarthMindConsensus.MinerProposal memory)
    {
        _params.vote = _vote;
        _params.proposalHash = Utils.hashMinerProposal(address(0), _params.vote, _params.message);
        return _params;
    }

    // function withMessage(EarthMindConsensus.MinerProposal memory _params, string memory _message)
    //     internal
    //     pure
    //     returns (EarthMindConsensus.MinerProposal memory)
    // {
    //     _params.message = _message;
    //     _params.proposalHash = Utils.hashMinerProposal(_vote, _message);
    //     return _params;
    // }
}
//  function withPoolId(CoraTypes.LenderInformation memory params, uint256 _poolId)
//         internal
//         pure
//         returns (CoraTypes.LenderInformation memory)
//     {
//         params.poolId = _poolId;
//         return params;
//     }
