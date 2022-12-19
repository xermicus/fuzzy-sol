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
    "contracts/CounterResolver.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.0;\n\nimport {IResolver} from \"./interfaces/IResolver.sol\";\n\ninterface ICounter {\n    function lastExecuted() external view returns (uint256);\n\n    function increaseCount(uint256 amount) external;\n}\n\ncontract CounterResolver is IResolver {\n    address public immutable COUNTER;\n\n    constructor(address _counter) {\n        COUNTER = _counter;\n    }\n\n    function checker()\n        external\n        view\n        override\n        returns (bool canExec, bytes memory execPayload)\n    {\n        uint256 lastExecuted = ICounter(COUNTER).lastExecuted();\n\n        canExec = (block.timestamp - lastExecuted) > 180;\n\n        execPayload = abi.encodeWithSelector(\n            ICounter.increaseCount.selector,\n            uint256(100)\n        );\n    }\n}\n"
    },
    "contracts/interfaces/IResolver.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.0;\n\ninterface IResolver {\n    function checker()\n        external\n        view\n        returns (bool canExec, bytes memory execPayload);\n}\n"
    }
  }
}}