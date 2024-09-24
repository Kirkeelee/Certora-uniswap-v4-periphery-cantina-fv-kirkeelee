// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import {Locker} from "../libraries/Locker.sol";

/// @notice A transient reentrancy lock, that stores the caller's address as the lock
contract ReentrancyLock {
    error ContractLocked();

    modifier isNotLocked() {
        if (Locker.get() != address(0)) revert ContractLocked();
        Locker.set(msg.sender);
        _;
        Locker.set(address(0));
    }

    function _getLocker() internal view returns (address) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00890000, 1037618708617) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00890001, 0) }
        return Locker.get();
    }
}
