// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC721} from "solmate/src/tokens/ERC721.sol";
import {EIP712_v4} from "./EIP712_v4.sol";
import {ERC721PermitHash} from "../libraries/ERC721PermitHash.sol";
import {SignatureVerification} from "permit2/src/libraries/SignatureVerification.sol";

import {IERC721Permit_v4} from "../interfaces/IERC721Permit_v4.sol";
import {UnorderedNonce} from "./UnorderedNonce.sol";

/// @title ERC721 with permit
/// @notice Nonfungible tokens that support an approve via signature, i.e. permit
abstract contract ERC721Permit_v4 is ERC721, IERC721Permit_v4, EIP712_v4, UnorderedNonce {
    using SignatureVerification for bytes;

    /// @notice Computes the nameHash and versionHash
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) EIP712_v4(name_) {}

    /// @notice Checks if the block's timestamp is before a signature's deadline
    modifier checkSignatureDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert SignatureDeadlineExpired();
        _;
    }

    /// @inheritdoc IERC721Permit_v4
    function permit(address spender, uint256 tokenId, uint256 deadline, uint256 nonce, bytes calldata signature)
        external
        payable
        checkSignatureDeadline(deadline)
    {
        // the .verify function checks the owner is non-0
        address owner = _ownerOf[tokenId];

        bytes32 digest = ERC721PermitHash.hashPermit(spender, tokenId, nonce, deadline);
        signature.verify(_hashTypedData(digest), owner);

        _useUnorderedNonce(owner, nonce);
        _approve(owner, spender, tokenId);
    }

    /// @inheritdoc IERC721Permit_v4
    function permitForAll(
        address owner,
        address operator,
        bool approved,
        uint256 deadline,
        uint256 nonce,
        bytes calldata signature
    ) external payable checkSignatureDeadline(deadline) {
        bytes32 digest = ERC721PermitHash.hashPermitForAll(operator, approved, nonce, deadline);
        signature.verify(_hashTypedData(digest), owner);

        _useUnorderedNonce(owner, nonce);
        _approveForAll(owner, operator, approved);
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    /// all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    /// multiple operators per owner.
    /// @dev Override Solmate's ERC721 setApprovalForAll so setApprovalForAll() and permit() share the _approveForAll method
    /// @param operator Address to add to the set of authorized operators
    /// @param approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address operator, bool approved) public override {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00240000, 1037618708516) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00240001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00241000, operator) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00241001, approved) }
        _approveForAll(msg.sender, operator, approved);
    }

    function _approveForAll(address owner, address operator, bool approved) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d0000, 1037618708605) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d1000, owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d1001, operator) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007d1002, approved) }
        isApprovedForAll[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev override Solmate's ERC721 approve so approve() and permit() share the _approve method
    /// Passing a spender address of zero can be used to remove any outstanding approvals
    /// Throws error unless `msg.sender` is the current NFT owner,
    /// or an authorized operator of the current owner.
    /// @param spender The new approved NFT controller
    /// @param id The tokenId of the NFT to approve
    function approve(address spender, uint256 id) public override {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00280000, 1037618708520) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00280001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00281000, spender) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00281001, id) }
        address owner = _ownerOf[id];

        if (msg.sender != owner && !isApprovedForAll[owner][msg.sender]) revert Unauthorized();

        _approve(owner, spender, id);
    }

    function _approve(address owner, address spender, uint256 id) internal {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e0000, 1037618708606) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e0001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e1000, owner) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e1001, spender) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007e1002, id) }
        getApproved[id] = spender;
        emit Approval(owner, spender, id);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f0000, 1037618708607) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f1000, spender) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff007f1001, tokenId) }
        return spender == ownerOf(tokenId) || getApproved[tokenId] == spender
            || isApprovedForAll[ownerOf(tokenId)][spender];
    }

    // TODO: to be implemented after audits
    function tokenURI(uint256) public pure override returns (string memory) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00200000, 1037618708512) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00200001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00205000, 0) }
        return "https://example.com";
    }
}
