// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00280000, 1037618708520) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00280001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00281000, id) }
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002c0000, 1037618708524) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002c0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002c1000, owner) }
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00350000, 1037618708533) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00350001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00351000, spender) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00351001, id) }
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00340000, 1037618708532) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00340001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00341000, operator) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00341001, approved) }
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00330000, 1037618708531) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00330001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00331000, from) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00331001, to) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00331002, id) }
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00230000, 1037618708515) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00230001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00231000, from) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00231001, to) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00231002, id) }
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00260000, 1037618708518) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00260001, 5) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00261000, from) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00261001, to) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00261002, id) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00263003, data.offset) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00262003, data.length) }
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002a0000, 1037618708522) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002a0001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002a1000, interfaceId) }
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f0000, 1037618708527) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f0001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f1000, to) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff002f1001, id) }
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00310000, 1037618708529) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00310001, 1) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00311000, id) }
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00320000, 1037618708530) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00320001, 2) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00321000, to) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00321001, id) }
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {assembly ("memory-safe") { mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00300000, 1037618708528) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00300001, 3) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00301000, to) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00301001, id) mstore(0xffffff6e4604afefe123321beef1b01fffffffffffffffffffffffff00301002, data) }
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
