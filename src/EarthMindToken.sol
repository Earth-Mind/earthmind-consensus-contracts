// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract EarthMindToken is ERC20 {
    constructor() ERC20("EarthMindToken", "EMT") {
        _mint(msg.sender, 100_000_000 ether);
    }
}
