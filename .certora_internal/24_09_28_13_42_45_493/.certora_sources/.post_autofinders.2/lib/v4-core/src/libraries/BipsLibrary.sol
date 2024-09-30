// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title For calculating a percentage of an amount, using bips
library BipsLibrary {
    uint256 internal constant BPS_DENOMINATOR = 10_000;

    /// @notice emitted when an invalid percentage is provided
    error InvalidBips();

    /// @param amount The total amount to calculate a percentage of
    /// @param bips The percentage to calculate, in bips
    function calculatePortion(uint256 amount, uint256 bips) internal pure returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00280000, 1037618708520) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00280001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00280005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00286001, bips) }
        if (bips > BPS_DENOMINATOR) revert InvalidBips();
        return (amount * bips) / BPS_DENOMINATOR;
    }
}
