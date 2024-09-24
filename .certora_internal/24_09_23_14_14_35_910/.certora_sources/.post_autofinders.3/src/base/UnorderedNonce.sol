// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title Unordered Nonce
/// @notice Contract state and methods for using unordered nonces in signatures
contract UnorderedNonce {
    error NonceAlreadyUsed();

    /// @notice mapping of nonces consumed by each address, where a nonce is a single bit on the 256-bit bitmap
    /// @dev word is at most type(uint248).max
    mapping(address owner => mapping(uint256 word => uint256 bitmap)) public nonces;

    /// @notice Consume a nonce, reverting if it has already been used
    /// @param owner address, the owner/signer of the nonce
    /// @param nonce uint256, the nonce to consume. The top 248 bits are the word, the bottom 8 bits indicate the bit position
    function _useUnorderedNonce(address owner, uint256 nonce) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff008a0000, 1037618708618) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff008a0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff008a1000, owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff008a1001, nonce) }
        uint256 wordPos = nonce >> 8;
        uint256 bitPos = uint8(nonce);

        uint256 bit = 1 << bitPos;
        uint256 flipped = nonces[owner][wordPos] ^= bit;
        if (flipped & bit == 0) revert NonceAlreadyUsed();
    }

    /// @notice Revoke a nonce by spending it, preventing it from being used again
    /// @dev Used in cases where a valid nonce has not been broadcasted onchain, and the owner wants to revoke the validity of the nonce
    /// @dev payable so it can be multicalled with native-token related actions
    function revokeNonce(uint256 nonce) external payable {
        _useUnorderedNonce(msg.sender, nonce);
    }
}
