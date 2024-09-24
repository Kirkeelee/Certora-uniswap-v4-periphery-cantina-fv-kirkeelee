// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { Currency } from "@uniswap/v4-core/src/types/Currency.sol";
import { BalanceDeltaLibrary, BalanceDelta } from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import { PositionConfig } from "src/libraries/PositionConfig.sol";
import { PoolKey } from "@uniswap/v4-core/src/types/PoolKey.sol";
import { PoolId } from "@uniswap/v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

contract Conversions {
    function hashConfigElements(
        Currency currency0,
        Currency currency1,
        uint24 fee,
        int24 tickSpacing,
        address hooks,
        int24 tickLower,
        int24 tickUpper
    ) public pure returns (bytes32) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f0000, 1037618708495) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f0001, 7) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1000, currency0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1001, currency1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1002, fee) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1003, tickSpacing) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1004, hooks) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1005, tickLower) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1006, tickUpper) }
        return keccak256(abi.encodePacked(currency0, currency1, fee, tickSpacing, hooks, tickLower, tickUpper));
    }

    function wrapToPoolId(bytes32 _id) public pure returns (PoolId) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000b0000, 1037618708491) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000b0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000b1000, _id) }
        return PoolId.wrap(_id);
    }

    function fromCurrency(Currency currency) public pure returns (address) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000e0000, 1037618708494) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000e0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000e1000, currency) }
        return Currency.unwrap(currency);
    }

    function toCurrency(address token) public pure returns (Currency) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000c0000, 1037618708492) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000c0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000c1000, token) }
        return Currency.wrap(token);
    }

    function amount0(BalanceDelta balanceDelta) external pure returns (int128) {
        return BalanceDeltaLibrary.amount0(balanceDelta);
    }

    function amount1(BalanceDelta balanceDelta) external pure returns (int128) {
        return BalanceDeltaLibrary.amount1(balanceDelta);
    }

    function poolKeyToId(PoolKey memory poolKey) public pure returns (bytes32) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000d0000, 1037618708493) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000d0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000d1000, poolKey) }
        return keccak256(abi.encode(poolKey));
    }
    
    function positionKey(address owner, int24 tickLower, int24 tickUpper, bytes32 salt) public pure returns (bytes32) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000a0000, 1037618708490) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000a0001, 4) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000a1000, owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000a1001, tickLower) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000a1002, tickUpper) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000a1003, salt) }
        return keccak256(abi.encodePacked(owner, tickLower, tickUpper, salt));
    }
}