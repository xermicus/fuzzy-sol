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
      "enabled": true,
      "runs": 200
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/ContextUpgradeable.sol\";\nimport \"../proxy/utils/Initializable.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    function __Ownable_init() internal initializer {\n        __Context_init_unchained();\n        __Ownable_init_unchained();\n    }\n\n    function __Ownable_init_unchained() internal initializer {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n    uint256[49] private __gap;\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n// solhint-disable-next-line compiler-version\npragma solidity ^0.8.0;\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n */\nabstract contract Initializable {\n\n    /**\n     * @dev Indicates that the contract has been initialized.\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice.\n     */\n    modifier initializer() {\n        require(_initializing || !_initialized, \"Initializable: contract is already initialized\");\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\nimport \"../proxy/utils/Initializable.sol\";\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract ContextUpgradeable is Initializable {\n    function __Context_init() internal initializer {\n        __Context_init_unchained();\n    }\n\n    function __Context_init_unchained() internal initializer {\n    }\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n    uint256[50] private __gap;\n}\n"
    },
    "contracts/core/ModuleMap.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol\";\nimport \"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol\";\nimport \"../interfaces/IModuleMap.sol\";\n\ncontract ModuleMap is IModuleMap, Initializable, OwnableUpgradeable {\n  mapping(Modules => address) private _moduleMap;\n\n  function initialize() public initializer {\n    __Ownable_init();\n  }\n\n  function getModuleAddress(Modules key)\n    public\n    view\n    override\n    returns (address)\n  {\n    return _moduleMap[key];\n  }\n\n  function setModuleAddress(Modules key, address value) public onlyOwner {\n    _moduleMap[key] = value;\n  }\n}\n"
    },
    "contracts/interfaces/IModuleMap.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\nenum Modules {\n  Kernel, // 0\n  UserPositions, // 1\n  YieldManager, // 2\n  IntegrationMap, // 3\n  BiosRewards, // 4\n  EtherRewards, // 5\n  SushiSwapTrader, // 6\n  UniswapTrader, // 7\n  StrategyMap, // 8\n  StrategyManager // 9\n}\n\ninterface IModuleMap {\n  function getModuleAddress(Modules key) external view returns (address);\n}\n"
    }
  }
}}