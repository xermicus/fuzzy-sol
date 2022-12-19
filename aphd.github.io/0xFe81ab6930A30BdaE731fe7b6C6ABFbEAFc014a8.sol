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
      "runs": 800
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
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"../utils/Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () internal {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"
    },
    "contracts/Registry.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract Registry is Ownable {\n    // Map asset addresses to indexes.\n    mapping(address => uint32) public assetAddressToIndex;\n    mapping(uint32 => address) public assetIndexToAddress;\n    uint32 numAssets = 0;\n\n    // Valid strategies.\n    mapping(address => uint32) public strategyAddressToIndex;\n    mapping(uint32 => address) public strategyIndexToAddress;\n    uint32 numStrategies = 0;\n\n    event AssetRegistered(address asset, uint32 assetId);\n    event StrategyRegistered(address strategy, uint32 strategyId);\n    event StrategyUpdated(address previousStrategy, address newStrategy, uint32 strategyId);\n\n    /**\n     * @notice Register a asset\n     * @param _asset The asset token address;\n     */\n    function registerAsset(address _asset) external onlyOwner {\n        require(_asset != address(0), \"Invalid asset\");\n        require(assetAddressToIndex[_asset] == 0, \"Asset already registered\");\n\n        // Register asset with an index >= 1 (zero is reserved).\n        numAssets++;\n        assetAddressToIndex[_asset] = numAssets;\n        assetIndexToAddress[numAssets] = _asset;\n\n        emit AssetRegistered(_asset, numAssets);\n    }\n\n    /**\n     * @notice Register a strategy\n     * @param _strategy The strategy contract address;\n     */\n    function registerStrategy(address _strategy) external onlyOwner {\n        require(_strategy != address(0), \"Invalid strategy\");\n        require(strategyAddressToIndex[_strategy] == 0, \"Strategy already registered\");\n\n        // Register strategy with an index >= 1 (zero is reserved).\n        numStrategies++;\n        strategyAddressToIndex[_strategy] = numStrategies;\n        strategyIndexToAddress[numStrategies] = _strategy;\n\n        emit StrategyRegistered(_strategy, numStrategies);\n    }\n\n    /**\n     * @notice Update the address of an existing strategy\n     * @param _strategy The strategy contract address;\n     * @param _strategyId The strategy ID;\n     */\n    function updateStrategy(address _strategy, uint32 _strategyId) external onlyOwner {\n        require(_strategy != address(0), \"Invalid strategy\");\n        require(strategyIndexToAddress[_strategyId] != address(0), \"Strategy doesn't exist\");\n\n        address previousStrategy = strategyIndexToAddress[_strategyId];\n        strategyAddressToIndex[previousStrategy] = 0;\n        strategyAddressToIndex[_strategy] = _strategyId;\n        strategyIndexToAddress[_strategyId] = _strategy;\n\n        emit StrategyUpdated(previousStrategy, _strategy, _strategyId);\n    }\n}\n"
    }
  }
}}