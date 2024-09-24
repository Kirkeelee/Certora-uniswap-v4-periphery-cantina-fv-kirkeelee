// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Library for reverting with custom errors efficiently
/// @notice Contains functions for reverting with custom errors with different argument types efficiently
/// @dev To use this library, declare `using CustomRevert for bytes4;` and replace `revert CustomError()` with
/// `CustomError.selector.revertWith()`
/// @dev The functions may tamper with the free memory pointer but it is fine since the call context is exited immediately
library CustomRevert {
    /// @dev Reverts with the selector of a custom error in the scratch space
    function revertWith(bytes4 selector) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00310000, 1037618708529) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00310001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00311000, selector) }
        assembly ("memory-safe") {
            mstore(0, selector)
            revert(0, 0x04)
        }
    }

    /// @dev Reverts with a custom error with an address argument in the scratch space
    function revertWith(bytes4 selector, address addr) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00320000, 1037618708530) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00320001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00321000, selector) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00321001, addr) }
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, and(addr, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with an int24 argument in the scratch space
    function revertWith(bytes4 selector, int24 value) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00340000, 1037618708532) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00340001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00341000, selector) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00341001, value) }
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, signextend(2, value))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with a uint160 argument in the scratch space
    function revertWith(bytes4 selector, uint160 value) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00350000, 1037618708533) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00350001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00351000, selector) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00351001, value) }
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, and(value, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with two int24 arguments
    function revertWith(bytes4 selector, int24 value1, int24 value2) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00330000, 1037618708531) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00330001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00331000, selector) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00331001, value1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00331002, value2) }
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), signextend(2, value1))
            mstore(add(fmp, 0x24), signextend(2, value2))
            revert(fmp, 0x44)
        }
    }

    /// @dev Reverts with a custom error with two uint160 arguments
    function revertWith(bytes4 selector, uint160 value1, uint160 value2) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00360000, 1037618708534) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00360001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00361000, selector) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00361001, value1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00361002, value2) }
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), and(value1, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(fmp, 0x24), and(value2, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(fmp, 0x44)
        }
    }

    /// @dev Reverts with a custom error with two address arguments
    function revertWith(bytes4 selector, address value1, address value2) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00370000, 1037618708535) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00370001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00371000, selector) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00371001, value1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00371002, value2) }
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
    function bubbleUpAndRevertWith(bytes4 selector, address addr) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00380000, 1037618708536) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00380001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00381000, selector) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00381001, addr) }
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
