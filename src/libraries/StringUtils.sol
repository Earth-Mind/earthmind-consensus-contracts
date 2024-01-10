// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library StringUtils {
    function stringToAddress(string memory str) public pure returns (address) {
        bytes memory stringBytes = bytes(str);
        require(stringBytes.length == 42, "Invalid address length"); // Including '0x'

        uint160 integerValue = 0;
        for (uint256 i = 2; i < 42; i++) {
            integerValue *= 16;

            // Convert ASCII character to hex value
            uint8 charCode = uint8(stringBytes[i]);
            if (charCode >= 48 && charCode <= 57) {
                // '0'-'9'
                integerValue += charCode - 48;
            } else if (charCode >= 65 && charCode <= 70) {
                // 'A'-'F'
                integerValue += charCode - 55;
            } else if (charCode >= 97 && charCode <= 102) {
                // 'a'-'f'
                integerValue += charCode - 87;
            } else {
                revert("Invalid character in address");
            }
        }

        return address(integerValue);
    }
}
