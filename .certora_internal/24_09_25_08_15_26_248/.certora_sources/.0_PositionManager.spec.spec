import "./setup/SafeTransferLibCVL.spec";
import "./setup/Deltas.spec";
import "./setup/EIP712.spec";
import "./setup/PoolManager.spec";

using PositionManagerHarness as Harness;

methods {
    function getPoolAndPositionInfo(uint256 tokenId) external returns (PositionManagerHarness.PoolKey, PositionManagerHarness.PositionInfo) envfree;
    function Harness.poolManager() external returns (address) envfree;
    function Harness.msgSender() external returns (address) envfree;

    // summaries for unresolved calls
    unresolved external in _._ => DISPATCH [
        PositionManagerHarness._
    ] default NONDET;
    function _.permit(address,IAllowanceTransfer.PermitSingle,bytes) external => NONDET;
    function _.permit(address,IAllowanceTransfer.PermitBatch,bytes) external => NONDET;
    function _.isValidSignature(bytes32, bytes memory) internal => NONDET;
    function _.isValidSignature(bytes32, bytes) external => NONDET;
    function _._call(address, bytes memory) internal => NONDET;
    function _._call(address, bytes) external => NONDET;
    function _.notifyUnsubscribe(uint256, PositionManagerHarness.PositionInfo, bytes) external => NONDET;
    function _.notifyUnsubscribe(uint256, PositionManagerHarness.PositionInfo memory, bytes memory) internal => NONDET;
    function _.notifyUnsubscribe(uint256) external => NONDET;
    // likely unsound, but assumes no callback
    function _.onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    ) external => NONDET; /* expects bytes4 */
}

use builtin rule sanity;

definition max_unt256() returns mathint = 2^255 - 1;

//  adding positive liquidity results in currency delta change for PositionManager
rule increaseLiquidityDecreasesBalances(env e) {
    uint256 tokenId; uint256 liquidity; uint128 amount0Max; uint128 amount1Max; bytes hookData;
    
    PositionManagerHarness.PoolKey poolKey; PositionManagerHarness.PositionInfo info;

    (poolKey, info) = getPoolAndPositionInfo(tokenId);
    require poolKey.hooks != currentContract;

    int256 delta0Before = getCurrencyDeltaExt(poolKey.currency0, currentContract);
    int256 delta1Before = getCurrencyDeltaExt(poolKey.currency1, currentContract);

    // deltas must be 0 at the start of any tx
    require delta0Before == 0;
    require delta1Before == 0;

    increaseLiquidity(e, tokenId, liquidity, amount0Max, amount1Max, hookData);

    int256 delta0After = getCurrencyDeltaExt(poolKey.currency0, currentContract);
    int256 delta1After = getCurrencyDeltaExt(poolKey.currency1, currentContract);

    assert liquidity != 0 => delta0After != 0 || delta1After != 0;
}


rule positionManagerSanctioned(address token, method f, env e, calldataarg args) filtered {
    f -> f.selector != sig:settlePair(Conversions.Currency,Conversions.Currency).selector
    && f.selector != sig:settle(Conversions.Currency,uint256,bool).selector
    && f.selector != sig:takePair(Conversions.Currency,Conversions.Currency,address).selector
    && f.selector != sig:take(Conversions.Currency,address,uint256).selector
    && f.selector != sig:close(Conversions.Currency).selector
    && f.selector != sig:sweep(Conversions.Currency,address).selector
    && f.contract == currentContract
} {
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;

    uint256 balanceBefore = balanceOfCVL(token, currentContract);
    
    f(e,args);

    uint256 balanceAfter = balanceOfCVL(token, currentContract);

    assert balanceAfter == balanceBefore;
}


rule lockerDoesntChange(method f, env e, calldataarg args) {
    address locker = msgSender(e); // calls _getLocker

    f(e,args);

    address newLocker = msgSender(e);

    assert newLocker == locker;
}

// minting changes increments tokenID, "!=" is used instead of "<" because of max_uint256 overflow.
rule MintingIncrementstokenId (env e) {

    PositionManagerHarness.PoolKey poolKey;
    int24 tickLower;
    int24 tickUpper;
    uint256 liquidity;
    uint128 amount0Max;
    uint128 amount1Max;
    address owner;
    bytes hookData;
    uint256 tokenIdBefore = getNextTokenId(e);
    require tokenIdBefore < max_unt256();

    mintPosition(e, poolKey, tickLower, tickUpper, liquidity, amount0Max, amount1Max, owner, hookData);

    uint256 tokenIdAfter = getNextTokenId(e); 
    address ownerOf = ownerOf(e, tokenIdBefore);

    assert tokenIdBefore == (tokenIdAfter - 1) || owner == ownerOf;

}

// no function should change the tokenId except minting.
rule onlyMintingchangesTokenID (method f, env e, calldataarg args) filtered {
    f -> f.selector != sig:mintPosition(Conversions.PoolKey, int24, int24, uint256, uint128, uint128, address, bytes).selector }{
    
    uint256 tokenIdBefore = getNextTokenId(e);

    f(e,args);

    uint256 tokenIdAfter = getNextTokenId(e);

    assert tokenIdBefore == tokenIdAfter;

}

//Effects of burn

rule BurnEffects (env e) {

    uint256 tokenId; uint128 amount0Min; uint128 amount1Min; bytes hookData;
    PositionManagerHarness.PoolKey poolKey; PositionManagerHarness.PositionInfo info;
   
    burnPosition(e, tokenId, amount0Min, amount1Min, hookData);
   
    (poolKey, info) = getPoolAndPositionInfo(e, tokenId);

    assert info ==0;

}
/*
//checking the modifier, this fails due to prover using different tokenId in args.
rule IsNotApprovedReverts(method f, env e, calldataarg args) filtered {
    f -> f.selector == sig:burnPosition(uint256, uint128, uint128,bytes).selector
    || f.selector == sig:decreaseLiquidity(uint256, uint256, uint128, uint128, bytes).selector
    || f.selector == sig:increaseLiquidity(uint256, uint256, uint128, uint128, bytes).selector
    } {
    address spender = msgSender(e);
    require e.msg.sender == spender;
    require e.msg.sender != currentContract;
    uint256 tokenId;
    bool isApproved = isApprovedOrOwner(e, spender, tokenId);
    require !isApproved;
   
    
    f@withrevert(e,args);
    


    assert lastReverted;
} */

rule burnPositionModifiercheck (env e) {
    address spender = msgSender(e);
    require e.msg.sender == spender;
    require e.msg.sender != currentContract;
    uint256 tokenId;
    bool isApproved = isApprovedOrOwner(e, spender, tokenId);
    uint128 amount0Min; uint128 amount1Min; bytes hookData;
    PositionManagerHarness.PoolKey poolKey; PositionManagerHarness.PositionInfo info;
    
    burnPosition@withrevert(e, tokenId, amount0Min, amount1Min, hookData);
    
    assert !isApproved => lastReverted;
}

rule increaseModifiercheck (env e) {
    uint256 tokenId; uint256 liquidity; uint128 amount0Max; uint128 amount1Max; bytes hookData;
    address spender = msgSender(e);
    require e.msg.sender == spender;
    require e.msg.sender != currentContract;
    bool isApproved = isApprovedOrOwner(e, spender, tokenId);
    
    increaseLiquidity@withrevert(e, tokenId, liquidity, amount0Max, amount1Max, hookData);
    

    assert !isApproved => lastReverted;
}

rule decreaseModifiercheck (env e) {
    uint256 tokenId; uint256 liquidity; uint128 amount0Max; uint128 amount1Max; bytes hookData;
    address spender = msgSender(e);
    require e.msg.sender == spender;
    require e.msg.sender != currentContract;
    bool isApproved = isApprovedOrOwner(e, spender, tokenId);
    
    decreaseLiquidity@withrevert(e, tokenId, liquidity, amount0Max, amount1Max, hookData);
    
    assert !isApproved => lastReverted;
}
/*
rule positionManagerBalanceChange(address token, method f, env e, calldataarg args) filtered {
    f -> f.selector == sig:settlePair(Conversions.Currency,Conversions.Currency).selector
    || f.selector == sig:settle(Conversions.Currency,uint256,bool).selector
    || f.selector == sig:takePair(Conversions.Currency,Conversions.Currency,address).selector
    || f.selector == sig:take(Conversions.Currency,address,uint256).selector
    || f.selector == sig:close(Conversions.Currency).selector
    || f.selector == sig:sweep(Conversions.Currency,address).selector
    } {
    require e.msg.sender == msgSender(e);
    require e.msg.sender != currentContract;

    uint256 balanceBefore = balanceOfCVL(token, currentContract);
    require balanceBefore != 0;
    
    f(e,args);

    uint256 balanceAfter = balanceOfCVL(token, currentContract);

    assert balanceAfter != balanceBefore;
}
*/

rule ActionsResultingInNegativeOrZeroDelta (method f, env e, calldataarg args) filtered {
   
    f -> f.selector == sig:take(Conversions.Currency,address,uint256).selector
    //|| f.selector == sig:close(Conversions.Currency).selector //need to separate as it fails here
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



rule ActionsResultingInNegativeOrZeroDeltaPaired(method f, env e, calldataarg args) filtered {
   
    f -> f.selector == sig:takePair(Conversions.Currency,Conversions.Currency,address).selector
    || f.selector == sig:decreaseLiquidity(uint256, uint256, uint128, uint128, bytes).selector
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