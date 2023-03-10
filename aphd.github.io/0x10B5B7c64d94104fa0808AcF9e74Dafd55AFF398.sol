{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": false,
      "runs": 200
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/NFTRarityRegister/INFTRarityRegister.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/// @title Registry holding the rarity value of a given NFT.\n/// @author Nemitari Ajienka @najienka\ninterface INFTRarityRegister {\n\t/**\n\t * The Staking SC allows to stake Prizes won via lottery which can be used to increase the APY of\n\t * staked tokens according to the rarity of NFT staked. For this reason,\n\t * we need to hold a table that the Staking SC can query and get back the rarity value of a given\n\t * NFT price (even the ones in the past).\n\t */\n\tevent NftRarityStored(\n\t\taddress indexed tokenAddress,\n\t\tuint256 tokenId,\n\t\tuint256 rarityValue\n\t);\n\n\t/**\n\t * @dev Store the rarity of a given NFT\n\t * @param tokenAddress The NFT smart contract address e.g., ERC-721 standard contract\n\t * @param tokenId The NFT's unique token id\n\t * @param rarityValue The rarity of a given NFT address and id unique combination\n\t */\n\tfunction storeNftRarity(address tokenAddress, uint256 tokenId, uint8 rarityValue) external;\n\n\t/**\n\t * @dev Get the rarity of a given NFT\n\t * @param tokenAddress The NFT smart contract address e.g., ERC-721 standard contract\n\t * @param tokenId The NFT's unique token id\n\t * @return The the rarity of a given NFT address and id unique combination and timestamp\n\t */\n\tfunction getNftRarity(address tokenAddress, uint256 tokenId) external view returns (uint8);\n}\n"
    },
    "contracts/NFTRarityRegister/NFTRarityRegister.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./INFTRarityRegister.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\n/// @title Registry holding the rarity value of a given NFT.\n/// @author Nemitari Ajienka @najienka\ncontract NFTRarityRegister is INFTRarityRegister, Ownable {\n\tmapping(address => mapping(uint256 => uint8)) private rarityRegister;\n\n\t/**\n\t * @dev Store the rarity of a given NFT\n\t * @param tokenAddress The NFT smart contract address e.g., ERC-721 standard contract\n\t * @param tokenId The NFT's unique token id\n\t * @param rarityValue The rarity of a given NFT address and id unique combination\n\t * using percentage i.e., 100% = 1000 to correct for precision and\n\t * to save gas required when converting from category, e.g.,\n\t * high, medium, low to percentage in staking contract\n\t * can apply rarityValue on interests directly after fetching\n\t */\n\tfunction storeNftRarity(address tokenAddress, uint tokenId, uint8 rarityValue) external override onlyOwner {\n\t\t// check tokenAddress, tokenId and rarityValue are valid\n\t\t// _exists ERC721 function is internal\n\t\trequire(tokenAddress != address(0), \"NFTRarityRegister: Token address is invalid\");\n\t\trequire(getNftRarity(tokenAddress, tokenId) == 0, \"NFTRarityRegister: Rarity already set for token\");\n\t\trequire(rarityValue >= 100, \"NFTRarityRegister: Value must be at least 100\");\n\n\t\trarityRegister[tokenAddress][tokenId] = rarityValue;\n\n\t\temit NftRarityStored(tokenAddress, tokenId, rarityValue);\n\t}\n\n\t/**\n\t * @dev Get the rarity of a given NFT\n\t * @param tokenAddress The NFT smart contract address e.g., ERC-721 standard contract\n\t * @param tokenId The NFT's unique token id\n\t * @return The the rarity of a given NFT address and id unique combination and timestamp\n\t */\n\tfunction getNftRarity(address tokenAddress, uint256 tokenId) public override view returns (uint8) {\n\t\treturn rarityRegister[tokenAddress][tokenId];\n\t}\n}"
    }
  }
}}