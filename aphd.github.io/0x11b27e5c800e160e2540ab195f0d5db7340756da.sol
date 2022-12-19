{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none"
    },
    "optimizer": {
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "jumpdestRemover": true,
        "orderLiterals": false,
        "peephole": true,
        "yul": false
      },
      "runs": 256
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
    "src/token/contracts/TransferHelper.sol": {
      "content": "// SPDX-License-Identifier: Unlicense\npragma solidity >=0.6.2;\n\ncontract TransferHelper {\n  function multicall (bytes calldata src) external {\n    assembly {\n      let ptr := src.offset\n      let end := add(ptr, src.length)\n      let to := calldataload(ptr)\n\n      ptr := add(ptr, 32)\n\n      for {} lt(ptr, end) {} {\n        let inSize := byte(callvalue(), calldataload(ptr))\n        ptr := add(ptr, 1)\n        calldatacopy(callvalue(), ptr, inSize)\n        ptr := add(ptr, inSize)\n\n        let success := call(gas(), to, callvalue(), callvalue(), inSize, callvalue(), callvalue())\n        if iszero(success) {\n          returndatacopy(callvalue(), callvalue(), returndatasize())\n          revert(callvalue(), returndatasize())\n        }\n      }\n    }\n  }\n}\n"
    }
  }
}}