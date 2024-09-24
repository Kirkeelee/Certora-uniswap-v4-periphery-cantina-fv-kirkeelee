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
    ) public pure returns (bytes32) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00140000, 1037618708500) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00140001, 7) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141000, currency0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141001, currency1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141002, fee) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141003, tickSpacing) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141004, hooks) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141005, tickLower) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00141006, tickUpper) }
        return keccak256(abi.encodePacked(currency0, currency1, fee, tickSpacing, hooks, tickLower, tickUpper));
    }

    function wrapToPoolId(bytes32 _id) public pure returns (PoolId) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00100000, 1037618708496) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00100001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00101000, _id) }
        return PoolId.wrap(_id);
    }

    function fromCurrency(Currency currency) public pure returns (address) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00130000, 1037618708499) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00130001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00131000, currency) }
        return Currency.unwrap(currency);
    }

    function toCurrency(address token) public pure returns (Currency) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00110000, 1037618708497) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00110001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00111000, token) }
        return Currency.wrap(token);
    }

    function amount0(BalanceDelta balanceDelta) external pure returns (int128) {
        return BalanceDeltaLibrary.amount0(balanceDelta);
    }

    function amount1(BalanceDelta balanceDelta) external pure returns (int128) {
        return BalanceDeltaLibrary.amount1(balanceDelta);
    }

    function poolKeyToId(PoolKey memory poolKey) public pure returns (bytes32) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00120000, 1037618708498) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00120001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00121000, poolKey) }
        return keccak256(abi.encode(poolKey));
    }
    
    function positionKey(address owner, int24 tickLower, int24 tickUpper, bytes32 salt) public pure returns (bytes32) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f0000, 1037618708495) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f0001, 4) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1000, owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1001, tickLower) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1002, tickUpper) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff000f1003, salt) }
        return keccak256(abi.encodePacked(owner, tickLower, tickUpper, salt));
    }
}