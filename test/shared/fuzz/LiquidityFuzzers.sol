// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta, toBalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {Fuzzers} from "@uniswap/v4-core/src/test/Fuzzers.sol";

import {IPositionManager} from "../../../src/interfaces/IPositionManager.sol";
import {Actions} from "../../../src/libraries/Actions.sol";
import {Planner, Plan} from "../../shared/Planner.sol";

contract LiquidityFuzzers is Fuzzers {
    using Planner for Plan;

    uint128 constant _MAX_SLIPPAGE_INCREASE = type(uint128).max;

    function addFuzzyLiquidity(
        IPositionManager lpm,
        address recipient,
        PoolKey memory key,
        IPoolManager.ModifyLiquidityParams memory params,
        uint160 sqrtPriceX96,
        bytes memory hookData
    ) internal returns (uint256, IPoolManager.ModifyLiquidityParams memory) {
        params = Fuzzers.createFuzzyLiquidityParams(key, params, sqrtPriceX96);

        Plan memory planner = Planner.init().add(
            Actions.MINT_POSITION,
            abi.encode(
                key,
                params.tickLower,
                params.tickUpper,
                uint256(params.liquidityDelta),
                _MAX_SLIPPAGE_INCREASE,
                _MAX_SLIPPAGE_INCREASE,
                recipient,
                hookData
            )
        );

        uint256 tokenId = lpm.nextTokenId();
        bytes memory calls = planner.finalizeModifyLiquidityWithClose(key);
        lpm.modifyLiquidities(calls, block.timestamp + 1);

        return (tokenId, params);
    }
}
