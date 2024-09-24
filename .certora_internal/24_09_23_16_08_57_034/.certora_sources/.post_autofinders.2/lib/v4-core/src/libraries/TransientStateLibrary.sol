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
    function getSyncedReserves(IPoolManager manager) internal view returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00530000, 1037618708563) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00530001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00531000, manager) }
        if (getSyncedCurrency(manager).isAddressZero()) return 0;
        return uint256(manager.exttload(CurrencyReserves.RESERVES_OF_SLOT));
    }

    function getSyncedCurrency(IPoolManager manager) internal view returns (Currency) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00540000, 1037618708564) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00540001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00541000, manager) }
        return Currency.wrap(address(uint160(uint256(manager.exttload(CurrencyReserves.CURRENCY_SLOT)))));
    }

    /// @notice Returns the number of nonzero deltas open on the PoolManager that must be zeroed out before the contract is locked
    function getNonzeroDeltaCount(IPoolManager manager) internal view returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00560000, 1037618708566) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00560001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00561000, manager) }
        return uint256(manager.exttload(NonzeroDeltaCount.NONZERO_DELTA_COUNT_SLOT));
    }

    /// @notice Get the current delta for a caller in the given currency
    /// @param target The credited account address
    /// @param currency The currency for which to lookup the delta
    function currencyDelta(IPoolManager manager, address target, Currency currency) internal view returns (int256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00570000, 1037618708567) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00570001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00571000, manager) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00571001, target) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00571002, currency) }
        bytes32 key;
        assembly ("memory-safe") {
            mstore(0, and(target, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(32, and(currency, 0xffffffffffffffffffffffffffffffffffffffff))
            key := keccak256(0, 64)
        }
        return int256(uint256(manager.exttload(key)));
    }

    /// @notice Returns whether the contract is unlocked or not
    function isUnlocked(IPoolManager manager) internal view returns (bool) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00550000, 1037618708565) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00550001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00551000, manager) }
        return manager.exttload(Lock.IS_UNLOCKED_SLOT) != 0x0;
    }
}
