{{
  "language": "Solidity",
  "sources": {
    "MerkleLib.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\n\npragma solidity 0.8.9;\n\nlibrary MerkleLib {\n\n    function verifyProof(bytes32 root, bytes32 leaf, bytes32[] memory proof) public pure returns (bool) {\n        bytes32 currentHash = leaf;\n\n        for (uint i = 0; i < proof.length; i += 1) {\n            currentHash = parentHash(currentHash, proof[i]);\n        }\n\n        return currentHash == root;\n    }\n\n    function parentHash(bytes32 a, bytes32 b) public pure returns (bytes32) {\n        if (a < b) {\n            return keccak256(abi.encode(a, b));\n        } else {\n            return keccak256(abi.encode(b, a));\n        }\n    }\n\n}\n"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "libraries": {
      "MerkleLib.sol": {}
    },
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
  }
}}