// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Library for reverting with custom errors efficiently
/// @notice Contains functions for reverting with custom errors with different argument types efficiently
/// @dev To use this library, declare `using CustomRevert for bytes4;` and replace `revert CustomError()` with
/// `CustomError.selector.revertWith()`
/// @dev The functions may tamper with the free memory pointer but it is fine since the call context is exited immediately
library CustomRevert {
    /// @dev Reverts with the selector of a custom error in the scratch space
    function revertWith(bytes4 selector) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00290000, 1037618708521) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00290001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00290005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00296000, selector) }
        assembly ("memory-safe") {
            mstore(0, selector)
            revert(0, 0x04)
        }
    }

    /// @dev Reverts with a custom error with an address argument in the scratch space
    function revertWith(bytes4 selector, address addr) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002a0000, 1037618708522) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002a0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002a0005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002a6001, addr) }
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, and(addr, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with an int24 argument in the scratch space
    function revertWith(bytes4 selector, int24 value) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002c0000, 1037618708524) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002c0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002c0005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002c6001, value) }
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, signextend(2, value))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with a uint160 argument in the scratch space
    function revertWith(bytes4 selector, uint160 value) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002d0000, 1037618708525) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002d0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002d0005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002d6001, value) }
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, and(value, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with two int24 arguments
    function revertWith(bytes4 selector, int24 value1, int24 value2) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002b0000, 1037618708523) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002b0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002b0005, 73) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002b6002, value2) }
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), signextend(2, value1))
            mstore(add(fmp, 0x24), signextend(2, value2))
            revert(fmp, 0x44)
        }
    }

    /// @dev Reverts with a custom error with two uint160 arguments
    function revertWith(bytes4 selector, uint160 value1, uint160 value2) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002e0000, 1037618708526) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002e0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002e0005, 73) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002e6002, value2) }
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), and(value1, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(fmp, 0x24), and(value2, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(fmp, 0x44)
        }
    }

    /// @dev Reverts with a custom error with two address arguments
    function revertWith(bytes4 selector, address value1, address value2) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f0000, 1037618708527) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f0005, 73) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f6002, value2) }
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), and(value1, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(fmp, 0x24), and(value2, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(fmp, 0x44)
        }
    }

    /// @notice bubble up the revert message returned by a call and revert with the selector provided
    /// @dev this function should only be used with custom errors of the type `CustomError(address target, bytes revertReason)`
    function bubbleUpAndRevertWith(bytes4 selector, address addr) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00300000, 1037618708528) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00300001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00300005, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00306001, addr) }
        assembly ("memory-safe") {
            let size := returndatasize()
            let fmp := mload(0x40)

            // Encode selector, address, offset, size, data
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), addr)
            mstore(add(fmp, 0x24), 0x40)
            mstore(add(fmp, 0x44), size)
            returndatacopy(add(fmp, 0x64), 0, size)

            // Ensure the size is a multiple of 32 bytes
            let encodedSize := add(0x64, mul(div(add(size, 31), 32), 32))
            revert(fmp, encodedSize)
        }
    }
}
