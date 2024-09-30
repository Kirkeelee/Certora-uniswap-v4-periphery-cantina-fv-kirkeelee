// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {SafeCast} from "@uniswap/v4-core/src/libraries/SafeCast.sol";

/// @title Slippage Check Library
/// @notice a library for checking if a delta exceeds a maximum ceiling or fails to meet a minimum floor
library SlippageCheck {
    using SafeCast for int128;

    error MaximumAmountExceeded(uint128 maximumAmount, uint128 amountRequested);
    error MinimumAmountInsufficient(uint128 minimumAmount, uint128 amountReceived);

    /// @notice Revert if one or both deltas does not meet a minimum output
    /// @param delta The principal amount of tokens to be removed, does not include any fees accrued
    /// @param amount0Min The minimum amount of token0 to receive
    /// @param amount1Min The minimum amount of token1 to receive
    /// @dev This should be called when removing liquidity (burn or decrease)
    function validateMinOut(BalanceDelta delta, uint128 amount0Min, uint128 amount1Min) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a70000, 1037618708647) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a70001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a71000, delta) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a71001, amount0Min) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a71002, amount1Min) }
        // Called on burn or decrease, where we expect the returned delta to be positive.
        // However, on pools where hooks can return deltas on modify liquidity, it is possible for a returned delta to be negative.
        // Because we use SafeCast, this will revert in those cases when the delta is negative.
        // This means this contract will NOT support pools where the hook returns a negative delta on burn/decrease.
        if (delta.amount0().toUint128() < amount0Min) {
            revert MinimumAmountInsufficient(amount0Min, delta.amount0().toUint128());
        }
        if (delta.amount1().toUint128() < amount1Min) {
            revert MinimumAmountInsufficient(amount1Min, delta.amount1().toUint128());
        }
    }

    /// @notice Revert if one or both deltas exceeds a maximum input
    /// @param delta The principal amount of tokens to be added, does not include any fees accrued (which is possible on increase)
    /// @param amount0Max The maximum amount of token0 to spend
    /// @param amount1Max The maximum amount of token1 to spend
    /// @dev This should be called when adding liquidity (mint or increase)
    function validateMaxIn(BalanceDelta delta, uint128 amount0Max, uint128 amount1Max) internal pure {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a80000, 1037618708648) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a80001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a81000, delta) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a81001, amount0Max) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00a81002, amount1Max) }
        // Called on mint or increase, where we expect the returned delta to be negative.
        // However, on pools where hooks can return deltas on modify liquidity, it is possible for a returned delta to be positive (even after discounting fees accrued).
        // Thus, we only cast the delta if it is guaranteed to be negative.
        // And we do NOT revert in the positive delta case. Since a positive delta means the hook is crediting tokens to the user for minting/increasing liquidity, we do not check slippage.
        // This means this contract will NOT support _positive_ slippage checks (minAmountOut checks) on pools where the hook returns a positive delta on mint/increase.
        int256 amount0 = delta.amount0();
        int256 amount1 = delta.amount1();
        if (amount0 < 0 && amount0Max < uint128(uint256(-amount0))) {
            revert MaximumAmountExceeded(amount0Max, uint128(uint256(-amount0)));
        }
        if (amount1 < 0 && amount1Max < uint128(uint256(-amount1))) {
            revert MaximumAmountExceeded(amount1Max, uint128(uint256(-amount1)));
        }
    }
}
