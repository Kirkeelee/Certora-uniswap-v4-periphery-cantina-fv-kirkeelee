import "./setup/PoolManager.spec";

using V4RouterHarness as Harness;

methods {
    // envfree
    function Harness.msgSender() external returns (address) envfree;


    // summaries for unresolved calls
    unresolved external in _._ => DISPATCH [
        V4RouterHarness._
    ] default NONDET;
    function _.permit(address,IAllowanceTransfer.PermitSingle,bytes) external => NONDET;
    function _.permit(address,IAllowanceTransfer.PermitBatch,bytes) external => NONDET;
    function _.isValidSignature(bytes32, bytes memory) internal => NONDET;
    function _.isValidSignature(bytes32, bytes) external => NONDET;
    function _._call(address, bytes memory) internal => NONDET;
    function _._call(address, bytes) external => NONDET;
    function _.notifyUnsubscribe(uint256, V4RouterHarness.PositionConfig, bytes) external => NONDET;
    function _.notifyUnsubscribe(uint256, V4RouterHarness.PositionConfig memory, bytes memory) internal => NONDET;
    // likely unsound, but assumes no callback
    function _.onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    ) external => NONDET; /* expects bytes4 */
}

use builtin rule sanity filtered { f -> f.contract == currentContract }

rule noBalanceOnRouter (address token, env e, method f, calldataarg args) filtered {
    f -> f.selector != sig:takeAll(Conversions.Currency,uint256).selector
    && f.selector != sig:settleAll(Conversions.Currency,uint256).selector
    && f.selector != sig:settleTakePair(Conversions.Currency,Conversions.Currency).selector
    && f.selector != sig:settle(Conversions.Currency,uint256,bool).selector
    && f.selector != sig:take(Conversions.Currency,address,uint256).selector
    && f.selector != sig:takePortion(Conversions.Currency,address,uint256).selector
    && f.contract == currentContract } {

    uint256 balanceBefore = balanceOfCVL(token, currentContract);

    f(e, args);

    uint256 balanceAfter = balanceOfCVL(token, currentContract);

    assert balanceBefore == balanceAfter;
}

/*
rule swapExactInRevertingCondition (env e) {

    IV4Router.ExactInputParams params;
    address swapper;
    Conversions.PoolKey key;
    bool zeroForOne;
    int256 amountSpecified;
    uint160 sqrtPriceLimitX96;
    mathint amountOut = swapMock(swapper, key, zeroForOne, amountSpecified, sqrtPriceLimitX96);

    swapExactIn@withrevert(e, params);

    assert (require_uint128(amountOut) < params.amountOutMinimum) => lastReverted;


}
*/

rule swapExactInSingleRevertingConditions (env e) {
   IV4Router.ExactInputSingleParams params;
    address swapper;
    require params.amountIn < 0;
    mathint amountOut = swapMock(swapper, params.poolKey, params.zeroForOne, params.amountIn, params.sqrtPriceLimitX96);

    swapExactInSingle@withrevert(e, params);

    assert (require_uint128(amountOut) < params.amountOutMinimum) => lastReverted;

}