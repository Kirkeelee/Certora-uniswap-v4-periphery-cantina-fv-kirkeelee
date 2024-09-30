// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPoolManager} from "../interfaces/IPoolManager.sol";
import {Currency} from "../types/Currency.sol";
import {CurrencyReserves} from "./CurrencyReserves.sol";
import {NonzeroDeltaCount} from "./NonzeroDeltaCount.sol";
import {Lock} from "./Lock.sol";

/// @notice A helper library to provide state getters that use exttload
library TransientStateLibrary {
    /// @notice returns the reserves for the synced currency
    /// @param manager The pool manager contract.

    /// @return uint256 The reserves of the currency.
    /// @dev returns 0 if the reserves are not synced or value is 0.
    /// Checks the synced currency to only return valid reserve values (after a sync and before a settle).
    function getSyncedReserves(IPoolManager manager) internal view returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00370000, 1037618708535) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00370001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00370005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00376000, manager) }
        if (getSyncedCurrency(manager).isAddressZero()) return 0;
        return uint256(manager.exttload(CurrencyReserves.RESERVES_OF_SLOT));
    }

    function getSyncedCurrency(IPoolManager manager) internal view returns (Currency) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00380000, 1037618708536) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00380001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00380005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00386000, manager) }
        return Currency.wrap(address(uint160(uint256(manager.exttload(CurrencyReserves.CURRENCY_SLOT)))));
    }

    /// @notice Returns the number of nonzero deltas open on the PoolManager that must be zeroed out before the contract is locked
    function getNonzeroDeltaCount(IPoolManager manager) internal view returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003a0000, 1037618708538) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003a0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003a0005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003a6000, manager) }
        return uint256(manager.exttload(NonzeroDeltaCount.NONZERO_DELTA_COUNT_SLOT));
    }

    /// @notice Get the current delta for a caller in the given currency
    /// @param target The credited account address
    /// @param currency The currency for which to lookup the delta
    function currencyDelta(IPoolManager manager, address target, Currency currency) internal view returns (int256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003b0000, 1037618708539) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003b0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003b0005, 73) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff003b6002, currency) }
        bytes32 key;
        assembly ("memory-safe") {
            mstore(0, and(target, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(32, and(currency, 0xffffffffffffffffffffffffffffffffffffffff))
            key := keccak256(0, 64)
        }
        return int256(uint256(manager.exttload(key)));
    }

    /// @notice Returns whether the contract is unlocked or not
    function isUnlocked(IPoolManager manager) internal view returns (bool) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00390000, 1037618708537) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00390001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00390005, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00396000, manager) }
        return manager.exttload(Lock.IS_UNLOCKED_SLOT) != 0x0;
    }
}
