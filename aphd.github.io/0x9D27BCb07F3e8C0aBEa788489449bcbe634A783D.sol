{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "constantinople",
    "libraries": {},
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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "pragma solidity ^0.5.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\n * the optional functions; to access them see {ERC20Detailed}.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "contracts/SimpleFaucet.sol": {
      "content": "// Copyright 2021 Cartesi Pte. Ltd.\n\n// SPDX-License-Identifier: Apache-2.0\n// Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use\n// this file except in compliance with the License. You may obtain a copy of the\n// License at http://www.apache.org/licenses/LICENSE-2.0\n\n// Unless required by applicable law or agreed to in writing, software distributed\n// under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR\n// CONDITIONS OF ANY KIND, either express or implied. See the License for the\n// specific language governing permissions and limitations under the License.\n\npragma solidity ^0.5.0;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ncontract SimpleFaucet {\n    uint256 public constant tokenAmount = 100000000000000000000000; // 100k CTSI\n    uint256 public constant waitTime = 4 weeks; // can request every 4 weeks\n\n    IERC20 public tokenInstance;\n\n    mapping(address => uint256) lastAccessTime;\n\n    constructor(address _tokenInstance) public {\n        require(_tokenInstance != address(0));\n        tokenInstance = IERC20(_tokenInstance);\n    }\n\n    function requestTokens() public {\n        require(allowedToWithdraw(msg.sender));\n        tokenInstance.transfer(msg.sender, tokenAmount);\n        lastAccessTime[msg.sender] = block.timestamp + waitTime;\n    }\n\n    function allowedToWithdraw(address _address) public view returns (bool) {\n        if (lastAccessTime[_address] == 0) {\n            return true;\n        } else if (block.timestamp >= lastAccessTime[_address]) {\n            return true;\n        }\n        return false;\n    }\n}\n"
    }
  }
}}