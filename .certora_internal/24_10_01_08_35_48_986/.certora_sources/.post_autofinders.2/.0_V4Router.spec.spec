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


rule ExactOutputDeltaIntegrity (env e) {
   IV4Router.ExactOutputParams params;
   require params.amountOut !=0;
   int256 deltaBefore = getCurrencyDeltaExt(params.currencyOut, currentContract);

   swapExactOut(e, params);

   int256 deltaAfter = getCurrencyDeltaExt(params.currencyOut, currentContract);

   assert (deltaBefore + params.amountOut) >= deltaAfter;
}*/

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
    f -> f.selector == sig:takeAll(Conversions.Currency, uint256).selector
     // || f.selector == sig:take(Conversions.Currency, address, uint256).selector
        } {
    Conversions.Currency currency;
    int256 deltaBefore = getCurrencyDeltaExt(currency, currentContract);
    require deltaBefore == 0;
    require e.msg.sender == currentContract;

    f(e, args);

    int256 deltaAfter = getCurrencyDeltaExt(currency, currentContract);
    assert deltaAfter >= deltaBefore;
}



rule RouterBalanceAfterSwaps(method f, env e, calldataarg args) filtered {
    f -> f.selector == sig:swapExactIn(IV4Router.ExactInputParams).selector
         || f.selector == sig:swapExactInSingle(IV4Router.ExactInputSingleParams).selector
         || f.selector == sig:swapExactOut(IV4Router.ExactOutputParams).selector
         || f.selector == sig:swapExactOutSingle(IV4Router.ExactOutputSingleParams).selector
} {
    Conversions.Currency anycurrency;
    uint256 balanceBeforeanycurrency = balanceOfCVL(anycurrency, currentContract);
    f(e, args);

    uint256 balanceAfteranycurrency = balanceOfCVL(anycurrency, currentContract);
    

    assert balanceBeforeanycurrency == balanceAfteranycurrency;
}

/*
rule BalanceOnRouter (Conversions.Currency token, env e, method f, calldataarg args) filtered {
    f -> f.selector == sig:takeAll(Conversions.Currency,uint256).selector
    || f.selector == sig:settleAll(Conversions.Currency,uint256).selector
    || f.selector == sig:settleTakePair(Conversions.Currency,Conversions.Currency).selector
    || f.selector == sig:settle(Conversions.Currency,uint256,bool).selector
    || f.selector == sig:take(Conversions.Currency,address,uint256).selector
    || f.selector == sig:takePortion(Conversions.Currency,address,uint256).selector
     } {
    require e.msg.sender == currentContract;
    uint256 balanceBefore = balanceOfCVL(token, currentContract);

    f(e, args);

    uint256 balanceAfter = balanceOfCVL(token, currentContract);

    assert balanceBefore != balanceAfter;
}*/

rule TakeAllEffects (env e) {
    Conversions.Currency currency;
    uint256 minAmount;
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;

    uint256 balanceBefore = balanceOfCVL(currency, currentContract);

    takeAll(e, currency, minAmount);

    uint256 balanceAfter = balanceOfCVL(currency, currentContract);

    assert balanceBefore >= balanceAfter;
}

rule TakeEffects (env e) {
    Conversions.Currency currency;
    uint256 amount;
    address recipient;
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;

    uint256 balanceBefore = balanceOfCVL(currency, currentContract);

    take(e, currency,recipient, amount);

    uint256 balanceAfter = balanceOfCVL(currency, currentContract);

    assert balanceBefore <= balanceAfter;
}

rule TakePortionEffects (env e) {
    Conversions.Currency currency;
    uint256 bps;
    address recipient;
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;

    uint256 balanceBefore = balanceOfCVL(currency, currentContract);

    takePortion(e, currency, recipient, bps);

    uint256 balanceAfter = balanceOfCVL(currency, currentContract);

    assert balanceBefore <= balanceAfter;
} 


rule SettleEffects (env e) {
    Conversions.Currency currency;
    require currency != NATIVE();
    uint256 amount;
    require amount != 0;

    bool payerIsUser;
    require !payerIsUser;
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;

    uint256 balanceBefore = balanceOfCVL(currency, currentContract);

    settle(e, currency, amount, payerIsUser);

    uint256 balanceAfter = balanceOfCVL(currency, currentContract);

    assert balanceBefore >= balanceAfter;
} 

rule SettleAllEffects (env e) {
    Conversions.Currency currency;
    uint256 MaxAmount;
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;
    
    uint256 balanceBefore = balanceOfCVL(currency, currentContract);

    settleAll(e, currency, MaxAmount);

    uint256 balanceAfter = balanceOfCVL(currency, currentContract);

    assert balanceBefore <= balanceAfter;
} 

rule settleTakePairEffects (env e) {
    Conversions.Currency settleCurrency;
    Conversions.Currency takeCurrency;
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;
    
    uint256 balanceBeforesettleCurrency = balanceOfCVL(settleCurrency, currentContract);
    uint256 balanceBeforetakeCurrency = balanceOfCVL(takeCurrency, currentContract);


    settleTakePair(e, settleCurrency, takeCurrency);

    uint256 balanceAftersettleCurrency = balanceOfCVL(settleCurrency, currentContract);
    uint256 balanceAftertakeCurrency = balanceOfCVL(takeCurrency, currentContract);


    assert balanceBeforesettleCurrency >= balanceAftersettleCurrency && balanceBeforetakeCurrency <= balanceAftertakeCurrency;
} 

rule SwapExactOutputBounds (env e) {
    IV4Router.ExactOutputParams params;
    require params.amountOut != 0;
    
    uint256 outputBefore = balanceOfCVL(params.currencyOut, currentContract);
    
    swapExactOut(e, params);

    uint256 outputAfter = balanceOfCVL(params.currencyOut, currentContract);
    
    assert outputBefore + params.amountOut >= outputAfter; // Ensure swap exact output does not violate bounds
}

rule SwapExactInputBounds (env e) {
    IV4Router.ExactInputParams params;
    require params.amountIn != 0;

    uint256 inputBefore = balanceOfCVL(params.currencyIn, currentContract);

    swapExactIn(e, params);
    uint256 inputAfter = balanceOfCVL(params.currencyIn, currentContract);
    
    assert inputBefore >= inputAfter; // Ensuring the correct input amount was swapped
}

rule SwapExactInputSingleBounds (env e) {
    IV4Router.ExactInputSingleParams params;
    require params.amountIn != 0;

    uint256 inputBefore = balanceOfCVL(params.poolKey.currency0, currentContract);

    swapExactInSingle(e, params);

    uint256 inputAfter = balanceOfCVL(params.poolKey.currency0, currentContract);

    assert inputBefore >= inputAfter; // Ensuring the correct input amount was swapped
}


rule SwapExactOutputSingleBounds (env e) {
    IV4Router.ExactOutputSingleParams params;
    require params.amountOut != 0;

    uint256 outputBefore = balanceOfCVL(params.poolKey.currency0, currentContract);

    swapExactOutSingle(e, params);

    uint256 outputAfter = balanceOfCVL(params.poolKey.currency0, currentContract);

    assert outputBefore + params.amountOut >= outputAfter; // Ensuring the exact output does not violate bounds
}

rule ValidPathCheck (env e) {
    IV4Router.ExactInputParams params;
    uint256 pathLength = params.path.length;

    require pathLength < 3 && pathLength != 0; // For multi-hop swaps

    swapExactIn(e, params);

    assert params.path[pathLength].intermediateCurrency != params.path[require_uint256(pathLength + 1)].intermediateCurrency;

    
}