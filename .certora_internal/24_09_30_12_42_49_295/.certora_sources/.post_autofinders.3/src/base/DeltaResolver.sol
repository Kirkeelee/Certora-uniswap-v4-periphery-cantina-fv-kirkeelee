// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {TransientStateLibrary} from "@uniswap/v4-core/src/libraries/TransientStateLibrary.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ImmutableState} from "./ImmutableState.sol";
import {ActionConstants} from "../libraries/ActionConstants.sol";

/// @notice Abstract contract used to sync, send, and settle funds to the pool manager
/// @dev Note that sync() is called before any erc-20 transfer in `settle`.
abstract contract DeltaResolver is ImmutableState {
    using TransientStateLibrary for IPoolManager;

    /// @notice Emitted trying to settle a positive delta.
    error DeltaNotPositive(Currency currency);
    /// @notice Emitted trying to take a negative delta.
    error DeltaNotNegative(Currency currency);

    /// @notice Take an amount of currency out of the PoolManager
    /// @param currency Currency to take
    /// @param recipient Address to receive the currency
    /// @param amount Amount to take
    function _take(Currency currency, address recipient, uint256 amount) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007b0000, 1037618708603) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007b0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007b1000, currency) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007b1001, recipient) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007b1002, amount) }
        poolManager.take(currency, recipient, amount);
    }

    /// @notice Pay and settle a currency to the PoolManager
    /// @dev The implementing contract must ensure that the `payer` is a secure address
    /// @param currency Currency to settle
    /// @param payer Address of the payer
    /// @param amount Amount to send
    function _settle(Currency currency, address payer, uint256 amount) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007c0000, 1037618708604) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007c0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007c1000, currency) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007c1001, payer) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007c1002, amount) }
        if (currency.isAddressZero()) {
            poolManager.settle{value: amount}();
        } else {
            poolManager.sync(currency);
            _pay(currency, payer, amount);
            poolManager.settle();
        }
    }

    /// @notice Abstract function for contracts to implement paying tokens to the poolManager
    /// @dev The recipient of the payment should be the poolManager
    /// @param token The token to settle. This is known not to be the native currency
    /// @param payer The address who should pay tokens
    /// @param amount The number of tokens to send
    function _pay(Currency token, address payer, uint256 amount) internal virtual;

    /// @notice Obtain the full amount owed by this contract (negative delta)
    /// @param currency Currency to get the delta for
    /// @return amount The amount owed by this contract as a uint256
    function _getFullDebt(Currency currency) internal view returns (uint256 amount) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e0000, 1037618708606) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e1000, currency) }
        int256 _amount = poolManager.currencyDelta(address(this), currency);
        // If the amount is positive, it should be taken not settled.
        if (_amount > 0) revert DeltaNotNegative(currency);
        // Casting is safe due to limits on the total supply of a pool
        amount = uint256(-_amount);
    }

    /// @notice Obtain the full credit owed to this contract (positive delta)
    /// @param currency Currency to get the delta for
    /// @return amount The amount owed to this contract as a uint256
    function _getFullCredit(Currency currency) internal view returns (uint256 amount) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d0000, 1037618708605) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d1000, currency) }
        int256 _amount = poolManager.currencyDelta(address(this), currency);
        // If the amount is negative, it should be settled not taken.
        if (_amount < 0) revert DeltaNotPositive(currency);
        amount = uint256(_amount);
    }

    /// @notice Calculates the amount for a settle action
    function _mapSettleAmount(uint256 amount, Currency currency) internal view returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f0000, 1037618708607) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f1000, amount) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f1001, currency) }
        if (amount == ActionConstants.CONTRACT_BALANCE) {
            return currency.balanceOfSelf();
        } else if (amount == ActionConstants.OPEN_DELTA) {
            return _getFullDebt(currency);
        } else {
            return amount;
        }
    }

    /// @notice Calculates the amount for a take action
    function _mapTakeAmount(uint256 amount, Currency currency) internal view returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00800000, 1037618708608) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00800001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00801000, amount) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00801001, currency) }
        if (amount == ActionConstants.OPEN_DELTA) {
            return _getFullCredit(currency);
        } else {
            return amount;
        }
    }
}
