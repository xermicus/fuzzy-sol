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
    "contracts/Counter.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.0;\n\ncontract Counter {\n    uint256 public count;\n    uint256 public lastExecuted;\n\n    function increaseCount(uint256 amount) external {\n        require(\n            ((block.timestamp - lastExecuted) > 180),\n            \"Counter: increaseCount: Time not elapsed\"\n        );\n\n        count += amount;\n        lastExecuted = block.timestamp;\n    }\n}\n"
    }
  }
}}