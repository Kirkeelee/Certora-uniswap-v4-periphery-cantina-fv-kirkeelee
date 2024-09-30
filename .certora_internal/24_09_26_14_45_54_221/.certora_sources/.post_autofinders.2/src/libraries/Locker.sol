// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

/// @notice This is a temporary library that allows us to use transient storage (tstore/tload)
/// TODO: This library can be deleted when we have the transient keyword support in solidity.
library Locker {
    // The slot holding the locker state, transiently. bytes32(uint256(keccak256("LockedBy")) - 1)
    bytes32 constant LOCKED_BY_SLOT = 0x0aedd6bde10e3aa2adec092b02a3e3e805795516cda41f27aa145b8f300af87a;

    function set(address locker) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00660000, 1037618708582) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00660001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00660005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00666000, locker) }
        assembly {
            tstore(LOCKED_BY_SLOT, locker)
        }
    }

    function get() internal view returns (address locker) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00670000, 1037618708583) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00670001, 0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00670004, 0) }
        assembly {
            locker := tload(LOCKED_BY_SLOT)
        }
    }
}
