// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {CustomRevert} from "./CustomRevert.sol";

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    using CustomRevert for bytes4;

    error SafeCastOverflow();

    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param x The uint256 to be downcasted
    /// @return y The downcasted integer, now type uint160
    function toUint160(uint256 x) internal pure returns (uint160 y) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003f0000, 1037618708543) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003f0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003f1000, x) }
        y = uint160(x);
        if (y != x) SafeCastOverflow.selector.revertWith();
    }

    /// @notice Cast a uint256 to a uint128, revert on overflow
    /// @param x The uint256 to be downcasted
    /// @return y The downcasted integer, now type uint128
    function toUint128(uint256 x) internal pure returns (uint128 y) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00400000, 1037618708544) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00400001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00401000, x) }
        y = uint128(x);
        if (x != y) SafeCastOverflow.selector.revertWith();
    }

    /// @notice Cast a int128 to a uint128, revert on overflow or underflow
    /// @param x The int128 to be casted
    /// @return y The casted integer, now type uint128
    function toUint128(int128 x) internal pure returns (uint128 y) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00420000, 1037618708546) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00420001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00421000, x) }
        if (x < 0) SafeCastOverflow.selector.revertWith();
        y = uint128(x);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param x The int256 to be downcasted
    /// @return y The downcasted integer, now type int128
    function toInt128(int256 x) internal pure returns (int128 y) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00430000, 1037618708547) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00430001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00431000, x) }
        y = int128(x);
        if (y != x) SafeCastOverflow.selector.revertWith();
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param x The uint256 to be casted
    /// @return y The casted integer, now type int256
    function toInt256(uint256 x) internal pure returns (int256 y) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00410000, 1037618708545) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00410001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00411000, x) }
        y = int256(x);
        if (y < 0) SafeCastOverflow.selector.revertWith();
    }

    /// @notice Cast a uint256 to a int128, revert on overflow
    /// @param x The uint256 to be downcasted
    /// @return The downcasted integer, now type int128
    function toInt128(uint256 x) internal pure returns (int128) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00440000, 1037618708548) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00440001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00441000, x) }
        if (x >= 1 << 127) SafeCastOverflow.selector.revertWith();
        return int128(int256(x));
    }
}
