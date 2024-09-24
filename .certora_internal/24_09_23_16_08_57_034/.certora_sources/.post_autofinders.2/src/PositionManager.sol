// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {SafeCast} from "@uniswap/v4-core/src/libraries/SafeCast.sol";
import {Position} from "@uniswap/v4-core/src/libraries/Position.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {TransientStateLibrary} from "@uniswap/v4-core/src/libraries/TransientStateLibrary.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";

import {ERC721Permit_v4} from "./base/ERC721Permit_v4.sol";
import {ReentrancyLock} from "./base/ReentrancyLock.sol";
import {IPositionManager} from "./interfaces/IPositionManager.sol";
import {Multicall_v4} from "./base/Multicall_v4.sol";
import {PoolInitializer} from "./base/PoolInitializer.sol";
import {DeltaResolver} from "./base/DeltaResolver.sol";
import {BaseActionsRouter} from "./base/BaseActionsRouter.sol";
import {Actions} from "./libraries/Actions.sol";
import {Notifier} from "./base/Notifier.sol";
import {CalldataDecoder} from "./libraries/CalldataDecoder.sol";
import {Permit2Forwarder} from "./base/Permit2Forwarder.sol";
import {SlippageCheck} from "./libraries/SlippageCheck.sol";
import {PositionInfo, PositionInfoLibrary} from "./libraries/PositionInfoLibrary.sol";

//                                           444444444
//                                444444444444      444444
//                              444              44     4444
//                             44         4      44        444
//                            44         44       44         44
//                           44          44        44         44
//                          44       444444          44        44
//                         444          4444           4444    44
//                         44             4444                 444444444444444444
//                         44             44  4                44444           444444
//        444444444444    44              4                444                      44
//        44        44444444              4             444                         44
//       444              44                          44                           444
//        44               4  4444444444444444444444444           4444444444     4444
//         44              44444444444444444444444444      444               44444
//          444                                  44 44444444444444444444444444
//           4444                             444444444444444444444444
//              4444                      444444    444444444444444
//                 44444              444444        44444444444444444444444
//                     444444444444444    4           44444 44444444444444444444
//                           444                          444444444444444444444444444
//                           444                           44444  44444444444     44444444
//                          444                               4   44444444444444   444444444
//                         4444 444                               44 4444444444444     44444444
//                         44  44444         44444444             44444444444444444444     44444
//                        444 444444        4444  4444             444444444444444444     44  4444
//                 4444   44  44444        44444444444             444444444444444444444    44444444
//                     44444   4444        4444444444             444444444444444444444444     44444
//                 44444 44444 444         444444                4444444444444444444444444       44444
//                       4444 44         44                     4 44444444444444444444444444   444 44444
//                   44444444 444  44   4    4         444444  4 44444444444444444444444444444   4444444
//                        444444    44       44444444444       44444444444444 444444444444444      444444
//                     444444 44   4444      44444       44     44444444444444444444444 4444444      44444
//                   44    444444   44   444444444 444        4444444444444444444444444444444444   4444444
//                       44  4444444444444    44  44  44       4444444444444444444444444444444       444444
//                      44  44444444444444444444444444  4   44 4444444444444444444444444444444    4   444444
//                     4    4444                     4    4 4444444444444444444444444              44 4444444
//                          4444                          4444444444444444444444444    4   4444     44444444
//                          4444                         444444444444444444444444  44444     44444 4444444444
//                          44444  44                  444444444444444444444444444444444444444444444444444444
//                          44444444444               4444444444444444444444444444444444444444444444444444444
//                           4444444444444           44444444444444444444444444444444444444444444444444444444
//                           444444444444444         444444444444444444444444444444444444444444444444444444444
//                            44444444444444444     4444444444444444444444444444444444444444444444444444444444
//                            44444444444444444     44444444444444444444444444444444444444444444444444444444
//                            44444444444444444444  444444444444444444444444444444444444444444444444444444444
//                            444444444444444444444 444444444444444444444444444444444444444444444444444444444
//                              444444444444444444444 4444444444444444444444444444444444444444444444444444444
//                              44444444444444444444444444444444444444444444444444444444444444444444444444444
//                               444444444444444444444444444444444444444444444444444444444444444444444444444
//                                44444444444444444444444444444444444444444444444444444444444444444444444444
//                               44444444444444444444444444444444444444444444444444      444444444444444444
//                             444444444444444444444444444444444444444444444444       44444444444444444444
//                           444   444   444   44  444444444444444444444 4444      444444444444444444444
//                           444  444    44    44  44444444 4444444444444       44444444444444444444444
//                            444 444   4444   4444 4444444444444444         44444444444444444444444444
//                      4444444444444444444444444444444444444444        44444444444444444444444444444
//                       444        4444444444444444444444444       44444444444444444444444444444444
//                          4444444       444444444444         4444444444444444444444444444444444
//                             4444444444                 44444444444444444444444444444444444
//                                444444444444444444444444444444444444444444444444444444
//                                     44444444444444444444444444444444444444444
//                                              4444444444444444444

/// @notice The PositionManager (PosM) contract is responsible for creating liquidity positions on v4.
/// PosM mints and manages ERC721 tokens associated with each position.
contract PositionManager is
    IPositionManager,
    ERC721Permit_v4,
    PoolInitializer,
    Multicall_v4,
    DeltaResolver,
    ReentrancyLock,
    BaseActionsRouter,
    Notifier,
    Permit2Forwarder
{
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;
    using TransientStateLibrary for IPoolManager;
    using SafeCast for uint256;
    using SafeCast for int256;
    using CalldataDecoder for bytes;
    using SlippageCheck for BalanceDelta;
    using PositionInfoLibrary for PositionInfo;

    /// @inheritdoc IPositionManager
    /// @dev The ID of the next token that will be minted. Skips 0
    uint256 public nextTokenId = 1;

    mapping(uint256 tokenId => PositionInfo info) public positionInfo;
    mapping(bytes25 poolId => PoolKey poolKey) public poolKeys;

    constructor(IPoolManager _poolManager, IAllowanceTransfer _permit2, uint256 _unsubscribeGasLimit)
        BaseActionsRouter(_poolManager)
        Permit2Forwarder(_permit2)
        ERC721Permit_v4("Uniswap V4 Positions NFT", "UNI-V4-POSM")
        Notifier(_unsubscribeGasLimit)
    {}

    /// @notice Reverts if the deadline has passed
    /// @param deadline The timestamp at which the call is no longer valid, passed in by the caller
    modifier checkDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert DeadlinePassed(deadline);
        _;
    }

    /// @notice Reverts if the caller is not the owner or approved for the ERC721 token
    /// @param caller The address of the caller
    /// @param tokenId the unique identifier of the ERC721 token
    /// @dev either msg.sender or msgSender() is passed in as the caller
    /// msgSender() should ONLY be used if this is called from within the unlockCallback, unless the codepath has reentrancy protection
    modifier onlyIfApproved(address caller, uint256 tokenId) override {
        if (!_isApprovedOrOwner(caller, tokenId)) revert NotApproved(caller);
        _;
    }

    /// @inheritdoc IPositionManager
    function modifyLiquidities(bytes calldata unlockData, uint256 deadline)
        external
        payable
        isNotLocked
        checkDeadline(deadline)
    {
        _executeActions(unlockData);
    }

    /// @inheritdoc IPositionManager
    function modifyLiquiditiesWithoutUnlock(bytes calldata actions, bytes[] calldata params)
        external
        payable
        isNotLocked
    {
        _executeActionsWithoutUnlock(actions, params);
    }

    /// @inheritdoc BaseActionsRouter
    function msgSender() public view override returns (address) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff001d0000, 1037618708509) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff001d0001, 0) }
        return _getLocker();
    }

    function _handleAction(uint256 action, bytes calldata params) internal virtual override {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00610000, 1037618708577) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00610001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00611000, action) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00613001, params.offset) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00612001, params.length) }
        if (action < Actions.SETTLE) {
            if (action == Actions.INCREASE_LIQUIDITY) {
                (uint256 tokenId, uint256 liquidity, uint128 amount0Max, uint128 amount1Max, bytes calldata hookData) =
                    params.decodeModifyLiquidityParams();
                _increase(tokenId, liquidity, amount0Max, amount1Max, hookData);
                return;
            } else if (action == Actions.DECREASE_LIQUIDITY) {
                (uint256 tokenId, uint256 liquidity, uint128 amount0Min, uint128 amount1Min, bytes calldata hookData) =
                    params.decodeModifyLiquidityParams();
                _decrease(tokenId, liquidity, amount0Min, amount1Min, hookData);
                return;
            } else if (action == Actions.MINT_POSITION) {
                (
                    PoolKey calldata poolKey,
                    int24 tickLower,
                    int24 tickUpper,
                    uint256 liquidity,
                    uint128 amount0Max,
                    uint128 amount1Max,
                    address owner,
                    bytes calldata hookData
                ) = params.decodeMintParams();
                _mint(poolKey, tickLower, tickUpper, liquidity, amount0Max, amount1Max, _mapRecipient(owner), hookData);
                return;
            } else if (action == Actions.BURN_POSITION) {
                // Will automatically decrease liquidity to 0 if the position is not already empty.
                (uint256 tokenId, uint128 amount0Min, uint128 amount1Min, bytes calldata hookData) =
                    params.decodeBurnParams();
                _burn(tokenId, amount0Min, amount1Min, hookData);
                return;
            }
        } else {
            if (action == Actions.SETTLE_PAIR) {
                (Currency currency0, Currency currency1) = params.decodeCurrencyPair();
                _settlePair(currency0, currency1);
                return;
            } else if (action == Actions.TAKE_PAIR) {
                (Currency currency0, Currency currency1, address recipient) = params.decodeCurrencyPairAndAddress();
                _takePair(currency0, currency1, _mapRecipient(recipient));
                return;
            } else if (action == Actions.SETTLE) {
                (Currency currency, uint256 amount, bool payerIsUser) = params.decodeCurrencyUint256AndBool();
                _settle(currency, _mapPayer(payerIsUser), _mapSettleAmount(amount, currency));
                return;
            } else if (action == Actions.TAKE) {
                (Currency currency, address recipient, uint256 amount) = params.decodeCurrencyAddressAndUint256();
                _take(currency, _mapRecipient(recipient), _mapTakeAmount(amount, currency));
                return;
            } else if (action == Actions.CLOSE_CURRENCY) {
                Currency currency = params.decodeCurrency();
                _close(currency);
                return;
            } else if (action == Actions.CLEAR_OR_TAKE) {
                (Currency currency, uint256 amountMax) = params.decodeCurrencyAndUint256();
                _clearOrTake(currency, amountMax);
                return;
            } else if (action == Actions.SWEEP) {
                (Currency currency, address to) = params.decodeCurrencyAndAddress();
                _sweep(currency, _mapRecipient(to));
                return;
            }
        }
        revert UnsupportedAction(action);
    }

    /// @dev Calling increase with 0 liquidity will credit the caller with any underlying fees of the position
    function _increase(
        uint256 tokenId,
        uint256 liquidity,
        uint128 amount0Max,
        uint128 amount1Max,
        bytes calldata hookData
    ) internal logInternal98(tokenId,liquidity,amount0Max,amount1Max,hookData)onlyIfApproved(msgSender(), tokenId) {
        (PoolKey memory poolKey, PositionInfo info) = getPoolAndPositionInfo(tokenId);

        // Note: The tokenId is used as the salt for this position, so every minted position has unique storage in the pool manager.
        (BalanceDelta liquidityDelta, BalanceDelta feesAccrued) =
            _modifyLiquidity(info, poolKey, liquidity.toInt256(), bytes32(tokenId), hookData);
        // Slippage checks should be done on the principal liquidityDelta which is the liquidityDelta - feesAccrued
        (liquidityDelta - feesAccrued).validateMaxIn(amount0Max, amount1Max);
    }modifier logInternal98(uint256 tokenId,uint256 liquidity,uint128 amount0Max,uint128 amount1Max,bytes calldata hookData) { assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00620000, 1037618708578) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00620001, 6) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00621000, tokenId) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00621001, liquidity) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00621002, amount0Max) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00621003, amount1Max) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00623004, hookData.offset) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00622004, hookData.length) } _; }

    /// @dev Calling decrease with 0 liquidity will credit the caller with any underlying fees of the position
    function _decrease(
        uint256 tokenId,
        uint256 liquidity,
        uint128 amount0Min,
        uint128 amount1Min,
        bytes calldata hookData
    ) internal logInternal100(tokenId,liquidity,amount0Min,amount1Min,hookData)onlyIfApproved(msgSender(), tokenId) {
        (PoolKey memory poolKey, PositionInfo info) = getPoolAndPositionInfo(tokenId);

        // Note: the tokenId is used as the salt.
        (BalanceDelta liquidityDelta, BalanceDelta feesAccrued) =
            _modifyLiquidity(info, poolKey, -(liquidity.toInt256()), bytes32(tokenId), hookData);
        // Slippage checks should be done on the principal liquidityDelta which is the liquidityDelta - feesAccrued
        (liquidityDelta - feesAccrued).validateMinOut(amount0Min, amount1Min);
    }modifier logInternal100(uint256 tokenId,uint256 liquidity,uint128 amount0Min,uint128 amount1Min,bytes calldata hookData) { assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00640000, 1037618708580) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00640001, 6) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00641000, tokenId) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00641001, liquidity) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00641002, amount0Min) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00641003, amount1Min) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00643004, hookData.offset) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00642004, hookData.length) } _; }

    function _mint(
        PoolKey calldata poolKey,
        int24 tickLower,
        int24 tickUpper,
        uint256 liquidity,
        uint128 amount0Max,
        uint128 amount1Max,
        address owner,
        bytes calldata hookData
    ) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00650000, 1037618708581) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00650001, 9) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00657000, poolKey)mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00651001, tickLower) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00651002, tickUpper) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00651003, liquidity) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00651004, amount0Max) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00651005, amount1Max) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00651006, owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00653007, hookData.offset) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00652007, hookData.length) }
        // mint receipt token
        uint256 tokenId;
        // tokenId is assigned to current nextTokenId before incrementing it
        unchecked {
            tokenId = nextTokenId++;
        }
        _mint(owner, tokenId);

        // Initialize the position info
        PositionInfo info = PositionInfoLibrary.initialize(poolKey, tickLower, tickUpper);
        positionInfo[tokenId] = info;

        // Store the poolKey if it is not already stored.
        // On UniswapV4, the minimum tick spacing is 1, which means that if the tick spacing is 0, the pool key has not been set.
        bytes25 poolId = info.poolId();
        if (poolKeys[poolId].tickSpacing == 0) {
            poolKeys[poolId] = poolKey;
        }

        // fee delta can be ignored as this is a new position
        (BalanceDelta liquidityDelta,) =
            _modifyLiquidity(info, poolKey, liquidity.toInt256(), bytes32(tokenId), hookData);
        liquidityDelta.validateMaxIn(amount0Max, amount1Max);
    }

    /// @dev this is overloaded with ERC721Permit_v4._burn
    function _burn(uint256 tokenId, uint128 amount0Min, uint128 amount1Min, bytes calldata hookData)
        internal
        logInternal99(tokenId,amount0Min,amount1Min,hookData)onlyIfApproved(msgSender(), tokenId)
    {
        (PoolKey memory poolKey, PositionInfo info) = getPoolAndPositionInfo(tokenId);

        uint256 liquidity = uint256(_getLiquidity(tokenId, poolKey, info.tickLower(), info.tickUpper()));

        // Clear the position info.
        positionInfo[tokenId] = PositionInfoLibrary.EMPTY_POSITION_INFO;
        // Burn the token.
        _burn(tokenId);

        // Can only call modify if there is non zero liquidity.
        if (liquidity > 0) {
            (BalanceDelta liquidityDelta, BalanceDelta feesAccrued) =
                _modifyLiquidity(info, poolKey, -(liquidity.toInt256()), bytes32(tokenId), hookData);
            // Slippage checks should be done on the principal liquidityDelta which is the liquidityDelta - feesAccrued
            (liquidityDelta - feesAccrued).validateMinOut(amount0Min, amount1Min);
        }

        if (info.hasSubscriber()) _unsubscribe(tokenId);
    }modifier logInternal99(uint256 tokenId,uint128 amount0Min,uint128 amount1Min,bytes calldata hookData) { assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00630000, 1037618708579) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00630001, 5) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00631000, tokenId) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00631001, amount0Min) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00631002, amount1Min) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00633003, hookData.offset) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00632003, hookData.length) } _; }

    function _settlePair(Currency currency0, Currency currency1) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00660000, 1037618708582) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00660001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00661000, currency0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00661001, currency1) }
        // the locker is the payer when settling
        address caller = msgSender();
        _settle(currency0, caller, _getFullDebt(currency0));
        _settle(currency1, caller, _getFullDebt(currency1));
    }

    function _takePair(Currency currency0, Currency currency1, address recipient) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00670000, 1037618708583) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00670001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00671000, currency0) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00671001, currency1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00671002, recipient) }
        _take(currency0, recipient, _getFullCredit(currency0));
        _take(currency1, recipient, _getFullCredit(currency1));
    }

    function _close(Currency currency) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00680000, 1037618708584) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00680001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00681000, currency) }
        // this address has applied all deltas on behalf of the user/owner
        // it is safe to close this entire delta because of slippage checks throughout the batched calls.
        int256 currencyDelta = poolManager.currencyDelta(address(this), currency);

        // the locker is the payer or receiver
        address caller = msgSender();
        if (currencyDelta < 0) {
            // Casting is safe due to limits on the total supply of a pool
            _settle(currency, caller, uint256(-currencyDelta));
        } else if (currencyDelta > 0) {
            _take(currency, caller, uint256(currencyDelta));
        }
    }

    /// @dev integrators may elect to forfeit positive deltas with clear
    /// if the forfeit amount exceeds the user-specified max, the amount is taken instead
    function _clearOrTake(Currency currency, uint256 amountMax) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00690000, 1037618708585) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00690001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00691000, currency) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00691001, amountMax) }
        uint256 delta = _getFullCredit(currency);

        // forfeit the delta if its less than or equal to the user-specified limit
        if (delta <= amountMax) {
            poolManager.clear(currency, delta);
        } else {
            _take(currency, msgSender(), delta);
        }
    }

    /// @notice Sweeps the entire contract balance of specified currency to the recipient
    function _sweep(Currency currency, address to) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006a0000, 1037618708586) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006a0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006a1000, currency) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006a1001, to) }
        uint256 balance = currency.balanceOfSelf();
        if (balance > 0) currency.transfer(to, balance);
    }

    function _modifyLiquidity(
        PositionInfo info,
        PoolKey memory poolKey,
        int256 liquidityChange,
        bytes32 salt,
        bytes calldata hookData
    ) internal returns (BalanceDelta liquidityDelta, BalanceDelta feesAccrued) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b0000, 1037618708587) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b0001, 6) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b1000, info) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b1001, poolKey) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b1002, liquidityChange) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b1003, salt) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b3004, hookData.offset) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006b2004, hookData.length) }
        (liquidityDelta, feesAccrued) = poolManager.modifyLiquidity(
            poolKey,
            IPoolManager.ModifyLiquidityParams({
                tickLower: info.tickLower(),
                tickUpper: info.tickUpper(),
                liquidityDelta: liquidityChange,
                salt: salt
            }),
            hookData
        );

        if (info.hasSubscriber()) {
            _notifyModifyLiquidity(uint256(salt), liquidityChange, feesAccrued);
        }
    }

    // implementation of abstract function DeltaResolver._pay
    function _pay(Currency currency, address payer, uint256 amount) internal override {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006c0000, 1037618708588) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006c0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006c1000, currency) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006c1001, payer) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006c1002, amount) }
        if (payer == address(this)) {
            currency.transfer(address(poolManager), amount);
        } else {
            // Casting from uint256 to uint160 is safe due to limits on the total supply of a pool
            permit2.transferFrom(payer, address(poolManager), uint160(amount), Currency.unwrap(currency));
        }
    }

    /// @notice an internal helper used by Notifier
    function _setSubscribed(uint256 tokenId) internal override {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006d0000, 1037618708589) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006d0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006d1000, tokenId) }
        positionInfo[tokenId] = positionInfo[tokenId].setSubscribe();
    }

    /// @notice an internal helper used by Notifier
    function _setUnsubscribed(uint256 tokenId) internal override {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006e0000, 1037618708590) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006e0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006e1000, tokenId) }
        positionInfo[tokenId] = positionInfo[tokenId].setUnsubscribe();
    }

    /// @dev overrides solmate transferFrom in case a notification to subscribers is needed
    function transferFrom(address from, address to, uint256 id) public virtual override {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00220000, 1037618708514) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00220001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00221000, from) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00221001, to) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00221002, id) }
        super.transferFrom(from, to, id);
        if (positionInfo[id].hasSubscriber()) _notifyTransfer(id, from, to);
    }

    /// @inheritdoc IPositionManager
    function getPoolAndPositionInfo(uint256 tokenId) public view returns (PoolKey memory poolKey, PositionInfo info) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00260000, 1037618708518) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00260001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00261000, tokenId) }
        info = positionInfo[tokenId];
        poolKey = poolKeys[info.poolId()];
    }

    /// @inheritdoc IPositionManager
    function getPositionLiquidity(uint256 tokenId) external view returns (uint128 liquidity) {
        (PoolKey memory poolKey, PositionInfo info) = getPoolAndPositionInfo(tokenId);
        liquidity = _getLiquidity(tokenId, poolKey, info.tickLower(), info.tickUpper());
    }

    function _getLiquidity(uint256 tokenId, PoolKey memory poolKey, int24 tickLower, int24 tickUpper)
        internal
        view
        returns (uint128 liquidity)
    {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006f0000, 1037618708591) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006f0001, 4) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006f1000, tokenId) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006f1001, poolKey) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006f1002, tickLower) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff006f1003, tickUpper) }
        bytes32 positionId = Position.calculatePositionKey(address(this), tickLower, tickUpper, bytes32(tokenId));
        liquidity = poolManager.getPositionLiquidity(poolKey.toId(), positionId);
    }
}
