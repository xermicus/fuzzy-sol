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
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.0;\n\nimport { PokeMeReady } from \"./PokeMeReady.sol\";\n\ncontract Counter is PokeMeReady {\n  uint256 public count;\n  uint256 public lastExecuted;\n\n  constructor(address payable _pokeMe) PokeMeReady(_pokeMe) {}\n\n  function increaseCount(uint256 amount) external onlyPokeMe {\n    require(\n      ((block.timestamp - lastExecuted) > 180),\n      \"Counter: increaseCount: Time not elapsed\"\n    );\n\n    count += amount;\n    lastExecuted = block.timestamp;\n  }\n}\n"
    },
    "contracts/PokeMeReady.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.0;\n\nabstract contract PokeMeReady {\n  address payable public immutable pokeMe;\n\n  constructor(address payable _pokeMe) {\n    pokeMe = _pokeMe;\n  }\n\n  modifier onlyPokeMe() {\n    require(msg.sender == pokeMe, \"PokeMeReady: onlyPokeMe\");\n    _;\n  }\n}\n"
    }
  }
}}