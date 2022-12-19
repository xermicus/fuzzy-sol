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
    "contracts/Forwarder.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.0;\n\ncontract Forwarder {\n    function checker(bytes memory execData)\n        external\n        pure\n        returns (bool, bytes memory)\n    {\n        return (true, execData);\n    }\n}\n"
    }
  }
}}