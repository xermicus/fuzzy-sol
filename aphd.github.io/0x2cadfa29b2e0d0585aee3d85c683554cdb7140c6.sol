{"BlockchainCutiesERC1155Interface.sol":{"content":"pragma solidity ^0.5.0;\n\ninterface BlockchainCutiesERC1155Interface {\n    function mintNonFungibleSingleShort(uint128 _type, address _to) external;\n    function mintNonFungibleSingle(uint256 _type, address _to) external;\n    function mintNonFungibleShort(uint128 _type, address[] calldata _to) external;\n    function mintNonFungible(uint256 _type, address[] calldata _to) external;\n    function mintFungibleSingle(uint256 _id, address _to, uint256 _quantity) external;\n    function mintFungible(uint256 _id, address[] calldata _to, uint256[] calldata _quantities) external;\n    function isNonFungible(uint256 _id) external pure returns(bool);\n    function ownerOf(uint256 _id) external view returns (address);\n    function totalSupplyNonFungible(uint256 _type) view external returns (uint256);\n    function totalSupplyNonFungibleShort(uint128 _type) view external returns (uint256);\n\n    /**\n        @notice A distinct Uniform Resource Identifier (URI) for a given token.\n        @dev URIs are defined in RFC 3986.\n        The URI may point to a JSON file that conforms to the \"ERC-1155 Metadata URI JSON Schema\".\n        @return URI string\n    */\n    function uri(uint256 _id) external view returns (string memory);\n    function proxyTransfer721(address _from, address _to, uint256 _tokenId, bytes calldata _data) external;\n    function proxyTransfer20(address _from, address _to, uint256 _tokenId, uint256 _value) external;\n    /**\n        @notice Get the balance of an account\u0027s Tokens.\n        @param _owner  The address of the token holder\n        @param _id     ID of the Token\n        @return        The _owner\u0027s balance of the Token type requested\n     */\n    function balanceOf(address _owner, uint256 _id) external view returns (uint256);\n    /**\n        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).\n        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see \"Approval\" section of the standard).\n        MUST revert if `_to` is the zero address.\n        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.\n        MUST revert on any other error.\n        MUST emit the `TransferSingle` event to reflect the balance change (see \"Safe Transfer Rules\" section of the standard).\n        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size \u003e 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see \"Safe Transfer Rules\" section of the standard).\n        @param _from    Source address\n        @param _to      Target address\n        @param _id      ID of the token type\n        @param _value   Transfer amount\n        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`\n    */\n    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;\n}\n"},"ERC721.sol":{"content":"pragma solidity ^0.5.0;\n\n/// @title ERC-721 Non-Fungible Token Standard\n/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md\n///  Note: the ERC-165 identifier for this interface is 0x6466353c\ninterface ERC721 /*is ERC165*/ {\n\n    /// @notice Query if a contract implements an interface\n    /// @param interfaceID The interface identifier, as specified in ERC-165\n    /// @dev Interface identification is specified in ERC-165. This function\n    ///  uses less than 30,000 gas.\n    /// @return `true` if the contract implements `interfaceID` and\n    ///  `interfaceID` is not 0xffffffff, `false` otherwise\n    function supportsInterface(bytes4 interfaceID) external view returns (bool);\n\n    /// @dev This emits when ownership of any NFT changes by any mechanism.\n    ///  This event emits when NFTs are created (`from` == 0) and destroyed\n    ///  (`to` == 0). Exception: during contract creation, any number of NFTs\n    ///  may be created and assigned without emitting Transfer. At the time of\n    ///  any transfer, the approved address for that NFT (if any) is reset to none.\n    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);\n\n    /// @dev This emits when the approved address for an NFT is changed or\n    ///  reaffirmed. The zero address indicates there is no approved address.\n    ///  When a Transfer event emits, this also indicates that the approved\n    ///  address for that NFT (if any) is reset to none.\n    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);\n\n    /// @dev This emits when an operator is enabled or disabled for an owner.\n    ///  The operator can manage all NFTs of the owner.\n    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);\n\n    /// @notice Count all NFTs assigned to an owner\n    /// @dev NFTs assigned to the zero address are considered invalid, and this\n    ///  function throws for queries about the zero address.\n    /// @param _owner An address for whom to query the balance\n    /// @return The number of NFTs owned by `_owner`, possibly zero\n    function balanceOf(address _owner) external view returns (uint256);\n\n    /// @notice Find the owner of an NFT\n    /// @dev NFTs assigned to zero address are considered invalid, and queries\n    ///  about them do throw.\n    /// @param _tokenId The identifier for an NFT\n    /// @return The address of the owner of the NFT\n    function ownerOf(uint256 _tokenId) external view returns (address);\n\n    /// @notice Transfers the ownership of an NFT from one address to another address\n    /// @dev Throws unless `msg.sender` is the current owner, an authorized\n    ///  operator, or the approved address for this NFT. Throws if `_from` is\n    ///  not the current owner. Throws if `_to` is the zero address. Throws if\n    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function\n    ///  checks if `_to` is a smart contract (code size \u003e 0). If so, it calls\n    ///  `onERC721Received` on `_to` and throws if the return value is not\n    ///  `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`.\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    /// @param data Additional data with no specified format, sent in call to `_to`\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;\n\n    /// @notice Transfers the ownership of an NFT from one address to another address\n    /// @dev This works identically to the other function with an extra data parameter,\n    ///  except this function just sets data to \"\"\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;\n\n    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE\n    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE\n    ///  THEY MAY BE PERMANENTLY LOST\n    /// @dev Throws unless `msg.sender` is the current owner, an authorized\n    ///  operator, or the approved address for this NFT. Throws if `_from` is\n    ///  not the current owner. Throws if `_to` is the zero address. Throws if\n    ///  `_tokenId` is not a valid NFT.\n    /// @param _from The current owner of the NFT\n    /// @param _to The new owner\n    /// @param _tokenId The NFT to transfer\n    function transferFrom(address _from, address _to, uint256 _tokenId) external;\n\n    /// @notice Set or reaffirm the approved address for an NFT\n    /// @dev The zero address indicates there is no approved address.\n    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized\n    ///  operator of the current owner.\n    /// @param _approved The new approved NFT controller\n    /// @param _tokenId The NFT to approve\n    function approve(address _approved, uint256 _tokenId) external;\n\n    /// @notice Enable or disable approval for a third party (\"operator\") to manage\n    ///  all your asset.\n    /// @dev Emits the ApprovalForAll event\n    /// @param _operator Address to add to the set of authorized operators.\n    /// @param _approved True if the operators is approved, false to revoke approval\n    function setApprovalForAll(address _operator, bool _approved) external;\n\n    /// @notice Get the approved address for a single NFT\n    /// @dev Throws if `_tokenId` is not a valid NFT\n    /// @param _tokenId The NFT to find the approved address for\n    /// @return The approved address for this NFT, or the zero address if there is none\n    function getApproved(uint256 _tokenId) external view returns (address);\n\n    /// @notice Query if an address is an authorized operator for another address\n    /// @param _owner The address that owns the NFTs\n    /// @param _operator The address that acts on behalf of the owner\n    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise\n    function isApprovedForAll(address _owner, address _operator) external view returns (bool);\n\n\n    /// @notice A descriptive name for a collection of NFTs in this contract\n    function name() external view returns (string memory _name);\n\n    /// @notice An abbreviated name for NFTs in this contract\n    function symbol() external view returns (string memory _symbol);\n\n\n    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.\n    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC\n    ///  3986. The URI may point to a JSON file that conforms to the \"ERC721\n    ///  Metadata JSON Schema\".\n    function tokenURI(uint256 _tokenId) external view returns (string memory);\n\n    /// @notice Count NFTs tracked by this contract\n    /// @return A count of valid NFTs tracked by this contract, where each one of\n    ///  them has an assigned and queryable owner not equal to the zero address\n    function totalSupply() external view returns (uint256);\n\n    /// @notice Enumerate valid NFTs\n    /// @dev Throws if `_index` \u003e= `totalSupply()`.\n    /// @param _index A counter less than `totalSupply()`\n    /// @return The token identifier for the `_index`th NFT,\n    ///  (sort order not specified)\n    function tokenByIndex(uint256 _index) external view returns (uint256);\n\n    /// @notice Enumerate NFTs assigned to an owner\n    /// @dev Throws if `_index` \u003e= `balanceOf(_owner)` or if\n    ///  `_owner` is the zero address, representing invalid NFTs.\n    /// @param _owner An address where we are interested in NFTs owned by them\n    /// @param _index A counter less than `balanceOf(_owner)`\n    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,\n    ///   (sort order not specified)\n    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);\n\n    /// @notice Transfers a Token to another address. When transferring to a smart\n    ///  contract, ensure that it is aware of ERC-721, otherwise the Token may be lost forever.\n    /// @param _to The address of the recipient, can be a user or contract.\n    /// @param _tokenId The ID of the Token to transfer.\n    function transfer(address _to, uint256 _tokenId) external;\n\n    function onTransfer(address _from, address _to, uint256 _nftIndex) external;\n}\n"},"Operators.sol":{"content":"pragma solidity ^0.5.0;\n\ncontract Operators {\n\n    mapping(address =\u003e bool) ownerAddress;\n    mapping(address =\u003e bool) operatorAddress;\n\n    constructor() public {\n        ownerAddress[msg.sender] = true;\n    }\n\n    modifier onlyOwner() {\n        require(ownerAddress[msg.sender], \"Access denied\");\n        _;\n    }\n\n    function isOwner(address _addr) public view returns (bool) {\n        return ownerAddress[_addr];\n    }\n\n    function addOwner(address _newOwner) external onlyOwner {\n        require(_newOwner != address(0), \"Owner cannot be zero\");\n\n        ownerAddress[_newOwner] = true;\n    }\n\n    function removeOwner(address _oldOwner) external onlyOwner {\n        delete(ownerAddress[_oldOwner]);\n    }\n\n    modifier onlyOperator() {\n        require(isOperator(msg.sender), \"Access denied\");\n        _;\n    }\n\n    function isOperator(address _addr) public view returns (bool) {\n        return operatorAddress[_addr] || ownerAddress[_addr];\n    }\n\n    function addOperator(address _newOperator) external onlyOwner {\n        require(_newOperator != address(0), \"Operator cannot be zero\");\n\n        operatorAddress[_newOperator] = true;\n    }\n\n    function removeOperator(address _oldOperator) external onlyOwner {\n        delete(operatorAddress[_oldOperator]);\n    }\n}\n"},"Proxy721_1155.sol":{"content":"pragma solidity ^0.5.0;\n\nimport \"./ERC721.sol\";\nimport \"./UriProviderInterface.sol\";\nimport \"./BlockchainCutiesERC1155Interface.sol\";\nimport \"./Operators.sol\";\n\ncontract Proxy721_1155 is ERC721, Operators {\n\n    BlockchainCutiesERC1155Interface public erc1155;\n\n    UriProviderInterface public uriProvider;\n    uint256 public nftType;\n    string public nftName;\n    string public nftSymbol;\n    bool public canSetup = true;\n\n    // The top bit is a flag to tell if this is a NFI.\n    uint256 constant public TYPE_NF_BIT = 1 \u003c\u003c 255;\n\n    // Mapping from owner to list of owned token IDs\n    mapping(address =\u003e mapping(uint256 =\u003e uint256)) private _ownedTokens;\n\n    // Mapping from token ID to index of the owner tokens list\n    mapping(uint256 =\u003e uint256) private _ownedTokensIndex;\n\n    modifier canBeStoredIn128Bits(uint256 _value) {\n        require(_value \u003c= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, \"ERC721: id overflow\");\n        _;\n    }\n\n    function setup(\n        BlockchainCutiesERC1155Interface _erc1155,\n        UriProviderInterface _uriProvider,\n        uint256 _nftType,\n        string calldata _nftSymbol,\n        string calldata _nftName\n    ) external onlyOwner canBeStoredIn128Bits(_nftType) {\n        require(canSetup, \"Contract already initialized\");\n        erc1155 = _erc1155;\n        uriProvider = _uriProvider;\n        nftType = (_nftType \u003c\u003c 128) | TYPE_NF_BIT;\n        nftSymbol = _nftSymbol;\n        nftName = _nftName;\n    }\n\n    function disableSetup() external onlyOwner {\n        canSetup = false;\n    }\n\n    /// @notice A descriptive name for a collection of NFTs in this contract\n    function name() external view returns (string memory) {\n        return nftName;\n    }\n\n    /// @notice An abbreviated name for NFTs in this contract\n    function symbol() external view returns (string memory) {\n        return nftSymbol;\n    }\n\n    /// @notice Count all NFTs assigned to an owner\n    /// @dev NFTs assigned to the zero address are considered invalid, and this\n    ///  function throws for queries about the zero address.\n    /// @param _owner An address for whom to query the balance\n    /// @return The number of NFTs owned by `_owner`, possibly zero\n    function balanceOf(address _owner) external view returns (uint256) {\n        return _balanceOf(_owner);\n    }\n\n    function _balanceOf(address _owner) internal view returns (uint256) {\n        require(_owner != address(0x0), \"ERC721: zero address cannot be owner\");\n        return erc1155.balanceOf(_owner, nftType);\n    }\n\n    /// @notice Find the owner of an NFT\n    /// @param _tokenIndex The index for an NFT with type nftType\n    /// @dev NFTs assigned to zero address are considered invalid, and queries\n    ///  about them do throw.\n    /// @return The address of the owner of the NFT\n    function ownerOf(uint256 _tokenIndex) external view returns (address) {\n        return _ownerOf(_tokenIndex);\n    }\n\n    function _ownerOf(uint256 _tokenIndex) internal view returns (address) {\n        return erc1155.ownerOf(_indexToId(_tokenIndex));\n    }\n\n    function _indexToId(uint256 _tokenIndex) internal view canBeStoredIn128Bits(_tokenIndex) returns (uint256) {\n        return nftType | _tokenIndex;\n    }\n\n    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.\n    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC\n    ///  3986. The URI may point to a JSON file that conforms to the \"ERC721\n    ///  Metadata JSON Schema\".\n    function tokenURI(uint256 _tokenIndex) external view canBeStoredIn128Bits(_tokenIndex) returns (string memory) {\n        return uriProvider.tokenURI(_tokenIndex);\n    }\n\n    /// @notice Count NFTs tracked by this contract\n    /// @return A count of valid NFTs tracked by this contract, where each one of\n    ///  them has an assigned and queryable owner not equal to the zero address\n    function totalSupply() external view returns (uint256) {\n        return _totalSupply();\n    }\n\n    function _totalSupply() internal view returns (uint256) {\n        return erc1155.totalSupplyNonFungible(nftType);\n    }\n\n    /// @notice Enumerate valid NFTs\n    /// @dev Throws if `_index` \u003e= `totalSupply()`.\n    /// @param _index A counter less than `totalSupply()`\n    /// @return The token identifier for the `_index`th NFT,\n    ///  (sort order not specified)\n    function tokenByIndex(uint256 _index) external view returns (uint256) {\n        require(_index \u003c _totalSupply(), \"ERC721: global index out of bounds\");\n        return _index - 1;\n    }\n\n    /// @notice Enumerate NFTs assigned to an owner\n    /// @dev Throws if `_index` \u003e= `balanceOf(_owner)` or if\n    ///  `_owner` is the zero address, representing invalid NFTs.\n    /// @param _owner An address where we are interested in NFTs owned by them\n    /// @param _index A counter less than `balanceOf(_owner)`\n    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,\n    ///   (sort order not specified)\n    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenIndex) {\n        require(_index \u003c _balanceOf(_owner), \"ERC721: owner index out of bounds\");\n        return _ownedTokens[_owner][_index];\n    }\n\n    /// @notice Transfers a Token to another address. When transferring to a smart\n    ///  contract, ensure that it is aware of ERC-721,\n    /// otherwise the Token may be lost forever.\n    /// @param _to The address of the recipient, can be a user or contract.\n    /// @param _tokenIndex The ID of the Token to transfer.\n    function transfer(address _to, uint256 _tokenIndex) external {\n        _transfer(msg.sender, _to, _tokenIndex, \"\");\n    }\n\n    function _transfer(address _from, address _to, uint256 _tokenIndex, bytes memory data) internal {\n        erc1155.proxyTransfer721(_from, _to, _indexToId(_tokenIndex), data);\n    }\n\n    function onTransfer(address _from, address _to, uint256 _nftIndex) external {\n        require(msg.sender == address(erc1155), \"ERC721: access denied\");\n\n        if (_from != address(0) \u0026\u0026 _from != _to) {\n            _removeTokenFromOwnerEnumeration(_from, _nftIndex);\n        }\n\n        if (_to != _from) {\n            _addTokenToOwnerEnumeration(_to, _nftIndex);\n        }\n\n        emit Transfer(_from, _to, _nftIndex);\n    }\n\n    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Metadata =\n        bytes4(keccak256(\u0027name()\u0027)) ^\n        bytes4(keccak256(\u0027symbol()\u0027)) ^\n        bytes4(keccak256(\u0027tokenURI(uint256)\u0027));\n\n    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Enumerable =\n        bytes4(keccak256(\u0027totalSupply()\u0027)) ^\n        bytes4(keccak256(\u0027tokenOfOwnerByIndex(address,uint256)\u0027)) ^\n        bytes4(keccak256(\u0027tokenByIndex(uint256)\u0027));\n\n    function supportsInterface(bytes4 interfaceID) external view returns (bool) {\n        return\n        interfaceID == 0x6466353c ||\n        interfaceID == 0x80ac58cd || // ERC721\n        interfaceID == INTERFACE_SIGNATURE_ERC721Metadata ||\n        interfaceID == INTERFACE_SIGNATURE_ERC721Enumerable ||\n        interfaceID == bytes4(keccak256(\u0027supportsInterface(bytes4)\u0027));\n    }\n\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external {\n        _transfer(_from, _to, _tokenId, data);\n    }\n\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {\n        _transfer(_from, _to, _tokenId, \"\");\n    }\n\n    function transferFrom(address _from, address _to, uint256 _tokenId) external {\n        _transfer(_from, _to, _tokenId, \"\");\n    }\n\n    function approve(address, uint256) external {\n        revert(\"ERC721: direct approve is not allowed\");\n    }\n\n    function setApprovalForAll(address, bool) external {\n        revert((\"ERC721: direct approve for all is not allowed\"));\n    }\n\n    function getApproved(uint256) external view returns (address) {\n        return address(0x0);\n    }\n\n    function isApprovedForAll(address, address) external view returns (bool) {\n        return false;\n    }\n\n    /**\n     * @dev Private function to add a token to this extension\u0027s ownership-tracking data structures.\n     * @param to address representing the new owner of the given token ID\n     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address\n     */\n    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {\n        uint256 length = _balanceOf(to);\n        _ownedTokens[to][length] = tokenId;\n        _ownedTokensIndex[tokenId] = length;\n    }\n\n    /**\n     * @dev Private function to remove a token from this extension\u0027s ownership-tracking data structures. Note that\n     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for\n     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).\n     * This has O(1) time complexity, but alters the order of the _ownedTokens array.\n     * @param from address representing the previous owner of the given token ID\n     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address\n     */\n    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {\n        // To prevent a gap in from\u0027s tokens array, we store the last token in the index of the token to delete, and\n        // then delete the last slot (swap and pop).\n\n        uint256 lastTokenIndex = _balanceOf(from) - 1;\n        uint256 tokenIndex = _ownedTokensIndex[tokenId];\n\n        // When the token to delete is the last token, the swap operation is unnecessary\n        if (tokenIndex != lastTokenIndex) {\n            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];\n\n            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token\n            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token\u0027s index\n        }\n\n        // This also deletes the contents at the last position of the array\n        delete _ownedTokensIndex[tokenId];\n        delete _ownedTokens[from][lastTokenIndex];\n    }\n}\n"},"UriProviderInterface.sol":{"content":"pragma solidity ^0.5.0;\n\n/// @title BlockchainCuties: Collectible and breedable cuties on the Ethereum blockchain.\n/// @author https://BlockChainArchitect.io\ninterface UriProviderInterface {\n    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.\n    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC\n    ///  3986. The URI may point to a JSON file that conforms to the \"ERC721\n    ///  Metadata JSON Schema\".\n    function tokenURI(uint256 _tokenId) external view returns (string memory infoUrl);\n}\n"}}