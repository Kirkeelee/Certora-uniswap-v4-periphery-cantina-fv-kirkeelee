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
  
    // Call the swap function and expect it to revert
    swapExactInSingle@withrevert(e, params);

   assert (params.amountOutMinimum == max_int128() ) => lastReverted;
   
}

   rule swapExactOutputSingleRevertingConditions (env e) {
   IV4Router.ExactOutputSingleParams params;
   require params.amountOut !=0;
     // Call the swap function and expect it to revert
    swapExactOutSingle@withrevert(e, params);

    assert (params.amountInMaximum == 0) => lastReverted;
    
     
}

