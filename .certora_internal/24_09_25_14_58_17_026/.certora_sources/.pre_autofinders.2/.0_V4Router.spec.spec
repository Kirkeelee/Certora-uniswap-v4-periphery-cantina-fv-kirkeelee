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


rule ActionsResultingInNegativeOrZeroDeltaPaired(method f, env e, calldataarg args) filtered {
   
    f -> f.selector == sig:takePair(Conversions.Currency,Conversions.Currency,address).selector
} {
    uint256 tokenId;     
    PositionManagerHarness.PoolKey poolKey; PositionManagerHarness.PositionInfo info;

    (poolKey, info) = getPoolAndPositionInfo(tokenId);
    int256 delta0Before = getCurrencyDeltaExt(poolKey.currency0, currentContract);
    int256 delta1Before = getCurrencyDeltaExt(poolKey.currency1, currentContract);


    require delta0Before == 0;

    f(e, args);

    int256 delta0After = getCurrencyDeltaExt(poolKey.currency0, currentContract);
    int256 delta1After = getCurrencyDeltaExt(poolKey.currency1, currentContract);


    assert delta0After <= 0 || delta1After <= 0;
   
}

rule ActionsResultingInNegativeOrZeroDelta (method f, env e, calldataarg args) filtered {
   
    f -> f.selector == sig:take(Conversions.Currency,address,uint256).selector
    || f.selector == sig:sweep(Conversions.Currency,address).selector
    || f.selector == sig:clearOrTake(Conversions.Currency,uint256).selector
} {
    uint256 tokenId;     
    PositionManagerHarness.PoolKey poolKey; PositionManagerHarness.PositionInfo info;

    (poolKey, info) = getPoolAndPositionInfo(tokenId);
    int256 delta0Before = getCurrencyDeltaExt(poolKey.currency0, currentContract);

    require delta0Before == 0;

    f(e, args);

    int256 delta0After = getCurrencyDeltaExt(poolKey.currency0, currentContract);

    assert delta0After <= 0;
   
}

rule NegativeorZeroDeltaAfterClose (env e) {
    uint256 tokenId;     
    PositionManagerHarness.PoolKey poolKey; PositionManagerHarness.PositionInfo info;

    (poolKey, info) = getPoolAndPositionInfo(tokenId);
    int256 delta0Before = getCurrencyDeltaExt(poolKey.currency0, currentContract);

    require delta0Before == 0;
    close(e, poolKey.currency0);

    int256 delta0After = getCurrencyDeltaExt(poolKey.currency0, currentContract);

    assert delta0After <= 0;
}