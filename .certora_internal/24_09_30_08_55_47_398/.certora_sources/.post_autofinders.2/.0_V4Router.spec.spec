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
  
   swapExactInSingle@withrevert(e, params);

   assert (params.amountOutMinimum == max_int128() ) => lastReverted;
   
}

rule swapExactInRevertingConditions (env e) {
   IV4Router.ExactInputParams params;
  
   swapExactIn@withrevert(e, params);

   assert (params.amountOutMinimum == max_int128() ) => lastReverted;
   
}
/*
   rule swapExactOutputSingleRevertingConditions (env e) {
   IV4Router.ExactOutputSingleParams params;
   require params.amountOut !=0;
   swapExactOutSingle@withrevert(e, params);

   assert (params.amountInMaximum == 0) => lastReverted;
    
     
}

   rule swapExactOutputRevertingConditions (env e) {
   IV4Router.ExactOutputParams params;
   require params.amountOut !=0;
   swapExactOut@withrevert(e, params);

   assert (params.amountInMaximum == 0) => lastReverted;
    
     
}
*/

rule ExactOutputDeltaIntegrity (env e) {
   IV4Router.ExactOutputParams params;
   require params.amountOut !=0;
   require params.amountInMaximum !=0;
   require params.amountOut != params.amountInMaximum;
   int256 deltaBefore = getCurrencyDeltaExt(params.currencyOut, currentContract);
   require deltaBefore ==0;
   require e.msg.sender == currentContract;


   swapExactOut(e, params);

   int256 deltaAfter = getCurrencyDeltaExt(params.currencyOut, currentContract);

   assert deltaBefore != deltaAfter;
}

rule CurrencyDeltaAfterSettlement(method f, env e, calldataarg args) filtered {
    f -> f.selector == sig:settle(Conversions.Currency, uint256, bool).selector
         || f.selector == sig:settleAll(Conversions.Currency, uint256).selector} {
    Conversions.Currency currency;
    int256 deltaBefore = getCurrencyDeltaExt(currency, currentContract);
    require deltaBefore == 0;
    require e.msg.sender == currentContract;

    f(e, args);

    int256 deltaAfter = getCurrencyDeltaExt(currency, currentContract);
    assert deltaAfter >= deltaBefore;
}

rule CurrencyDeltaAfterTake(method f, env e, calldataarg args) filtered {
    f -> f.selector == sig:take(Conversions.Currency, address, uint256).selector
         || f.selector == sig:takeAll(Conversions.Currency, uint256).selector} {
    Conversions.Currency currency;
    int256 deltaBefore = getCurrencyDeltaExt(currency, currentContract);
    require deltaBefore == 0;
    require e.msg.sender == currentContract;

    f(e, args);

    int256 deltaAfter = getCurrencyDeltaExt(currency, currentContract);
    assert deltaAfter >= deltaBefore;
}
