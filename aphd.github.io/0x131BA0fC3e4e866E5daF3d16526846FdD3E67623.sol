{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
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
    "contracts/NdxRewardSchedule.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.6.12;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"./interfaces/IRewardsSchedule.sol\";\n\n\n/**\n * @dev Rewards schedule that distributes 1,500,000 tokens over two years using a linear\n * decay that distributes roughly 1.7 tokens in the first block for every 0.3 tokens in the\n * last block.\n *\n * A value of 13.2 seconds was selected as the average block time to set 4778182 as the number\n * of blocks in 2 years. This has been a stable block time for roughly a year at the time of\n * writing.\n */\ncontract NDXRewardsSchedule is Ownable, IRewardsSchedule {\n  uint256 public immutable override startBlock;\n  uint256 public override endBlock;\n\n  constructor(uint256 startBlock_) public Ownable() {\n    startBlock = startBlock_;\n    endBlock = startBlock_ + 4778181;\n  }\n\n  /**\n   * @dev Set an early end block for rewards.\n   * Note: This can only be called once.\n   */\n  function setEarlyEndBlock(uint256 earlyEndBlock) external override onlyOwner {\n    uint256 endBlock_ = endBlock;\n    require(endBlock_ == startBlock + 4778181, \"Early end block already set\");\n    require(earlyEndBlock > block.number && earlyEndBlock > startBlock, \"End block too early\");\n    require(earlyEndBlock < endBlock_, \"End block too late\");\n    endBlock = earlyEndBlock;\n    emit EarlyEndBlockSet(earlyEndBlock);\n  }\n\n  function getRewardsForBlockRange(uint256 from, uint256 to) external view override returns (uint256) {\n    require(to >= from, \"Bad block range\");\n    uint256 endBlock_ = endBlock;\n    // If queried range is entirely outside of reward blocks, return 0\n    if (from >= endBlock_ || to <= startBlock) return 0;\n\n    // Use start/end values where from/to are OOB\n    if (to > endBlock_) to = endBlock_;\n    if (from < startBlock) from = startBlock;\n\n    uint256 x = from - startBlock;\n    uint256 y = to - startBlock;\n\n    // This formula is the definite integral of the following function:\n    // rewards(b) = 0.5336757788 - 0.00000009198010879*b; b >= 0; b < 4778182\n    // where b is the block number offset from {startBlock} and the output is multiplied by 1e18.\n    return (45990054395 * x**2)\n      + (5336757788e8 * (y - x))\n      - (45990054395 * y**2);\n  }\n}\n\n"
    },
    "contracts/interfaces/IRewardsSchedule.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.6.12;\n\n\ninterface IRewardsSchedule {\n  event EarlyEndBlockSet(uint256 earlyEndBlock);\n\n  function startBlock() external view returns (uint256);\n  function endBlock() external view returns (uint256);\n  function getRewardsForBlockRange(uint256 from, uint256 to) external view returns (uint256);\n  function setEarlyEndBlock(uint256 earlyEndBlock) external;\n}"
    }
  }
}}