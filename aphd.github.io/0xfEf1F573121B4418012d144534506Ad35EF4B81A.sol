{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 1000
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
    "contracts/0xerc1155/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport '../utils/Context.sol';\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n  address private _owner;\n\n  event OwnershipTransferred(\n    address indexed previousOwner,\n    address indexed newOwner\n  );\n\n  /**\n   * @dev Initializes the contract setting the deployer as the initial owner.\n   */\n  constructor() {\n    address msgSender = _msgSender();\n    _owner = msgSender;\n    emit OwnershipTransferred(address(0), msgSender);\n  }\n\n  /**\n   * @dev Returns the address of the current owner.\n   */\n  function owner() public view virtual returns (address) {\n    return _owner;\n  }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(owner() == _msgSender(), 'Ownable: Access denied');\n    _;\n  }\n\n  /**\n   * @dev Leaves the contract without owner. It will not be possible to call\n   * `onlyOwner` functions anymore. Can only be called by the current owner.\n   *\n   * NOTE: Renouncing ownership will leave the contract without an owner,\n   * thereby removing any functionality that is only available to the owner.\n   */\n  function renounceOwnership() public virtual onlyOwner {\n    emit OwnershipTransferred(_owner, address(0));\n    _owner = address(0);\n  }\n\n  /**\n   * @dev Transfers ownership of the contract to a new account (`newOwner`).\n   * Can only be called by the current owner.\n   */\n  function transferOwnership(address newOwner) public virtual onlyOwner {\n    require(newOwner != address(0), 'Ownable: Zero address');\n    emit OwnershipTransferred(_owner, newOwner);\n    _owner = newOwner;\n  }\n}\n"
    },
    "contracts/0xerc1155/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.7.6;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n  function _msgSender() internal view virtual returns (address payable) {\n    return msg.sender;\n  }\n\n  function _msgData() internal view virtual returns (bytes memory) {\n    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n    return msg.data;\n  }\n}\n"
    },
    "contracts/src/utils/AddressRegistry.sol": {
      "content": "/*\n * Copyright (C) 2021 The Wolfpack\n * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance\n *\n * SPDX-License-Identifier: Apache-2.0\n * See the file LICENSES/README.md for more information.\n */\n\nimport '../../0xerc1155/access/Ownable.sol';\n\nimport './interfaces/IAddressRegistry.sol';\n\npragma solidity >=0.7.0 <0.8.0;\n\ncontract AddressRegistry is IAddressRegistry, Ownable {\n  mapping(bytes32 => address) public registry;\n\n  constructor(address _owner) {\n    transferOwnership(_owner);\n  }\n\n  function setRegistryEntry(bytes32 _key, address _location)\n    external\n    override\n    onlyOwner\n  {\n    registry[_key] = _location;\n  }\n\n  function getRegistryEntry(bytes32 _key)\n    external\n    view\n    override\n    returns (address)\n  {\n    require(registry[_key] != address(0), 'no address for key');\n    return registry[_key];\n  }\n}\n"
    },
    "contracts/src/utils/interfaces/IAddressRegistry.sol": {
      "content": "/*\n * Copyright (C) 2021 The Wolfpack\n * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance\n *\n * SPDX-License-Identifier: Apache-2.0\n * See the file LICENSES/README.md for more information.\n */\n\npragma solidity >=0.7.0 <0.8.0;\n\ninterface IAddressRegistry {\n  /**\n   * @dev Set an abitrary key / address pair into the registry\n   */\n  function setRegistryEntry(bytes32 _key, address _location) external;\n\n  /**\n   * @dev Get a registry enty with by key, returns 0 address if not existing\n   */\n  function getRegistryEntry(bytes32 _key) external view returns (address);\n}\n"
    }
  }
}}