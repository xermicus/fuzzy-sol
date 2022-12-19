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
    "contracts/Lockup.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.7.6;\n\ninterface IERC20 {\n  function balanceOf(address account) external view returns (uint256);\n  function transfer(address recipient, uint256 amount) external returns (bool);\n}\n\n\ncontract Lockup {\n  address public immutable recipient;\n  address public immutable token;\n  uint256 public immutable unlockAt;\n  \n  constructor(address _recipient, address _token, uint256 lockDuration) {\n    recipient = _recipient;\n    token = _token;\n    unlockAt = block.timestamp + lockDuration;\n  }\n\n  function release() external {\n    require(block.timestamp >= unlockAt, \"Timelock has not passed\");\n    IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));\n  }\n}"
    }
  }
}}