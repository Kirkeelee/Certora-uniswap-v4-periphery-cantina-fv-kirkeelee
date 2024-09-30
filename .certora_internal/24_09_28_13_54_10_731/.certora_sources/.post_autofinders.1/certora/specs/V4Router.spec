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

definition max_int128() returns mathint = 2^128 - 1; 

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


rule swapExactInSingleRevertingConditions (env e) {
   IV4Router.ExactInputSingleParams params;
    address swapper;

    require swapper == currentContract;
    require params.sqrtPriceLimitX96 !=0;

    Conversions.BalanceDelta delta = swapMock(swapper, params.poolKey, params.zeroForOne, require_int256(-require_int256(params.amountIn)), params.sqrtPriceLimitX96);

    // Cache amounts before the swap
    int128 amount0 = Conv.amount0(delta);
    int128 amount1 = Conv.amount1(delta);



    // Call the swap function and expect it to revert
    swapExactInSingle@withrevert(e, params);

   assert (params.amountOutMinimum == max_int128() ) => lastReverted;
   
}

   rule swapExactOutputSingleRevertingConditions (env e) {
   IV4Router.ExactOutputSingleParams params;
    address swapper;
     // Call swapMock to simulate the swap

    require swapper == currentContract;
    require params.sqrtPriceLimitX96 !=0;
    Conversions.BalanceDelta delta = swapMock(swapper, params.poolKey, params.zeroForOne, params.amountOut, params.sqrtPriceLimitX96);

    // Cache amounts before the swap
    int128 amount0 = Conv.amount0(delta);
    int128 amount1 = Conv.amount1(delta);
    

    // Call the swap function and expect it to revert
    swapExactOutSingle@withrevert(e, params);

    assert (params.amountInMaximum == max_int128() ) => lastReverted;
    
     
}

