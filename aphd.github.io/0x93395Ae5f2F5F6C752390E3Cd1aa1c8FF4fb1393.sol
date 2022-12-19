{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 999999
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
    "contracts/formulas/EdenFormula.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"../lib/VotingPowerFormula.sol\";\n\n/**\n * @title EdenFormula\n * @dev Convert EDEN to voting power\n */\ncontract EdenFormula is VotingPowerFormula {\n    /**\n     * @notice Convert EDEN amount to voting power\n     * @dev Always converts 1-1\n     * @param amount token amount\n     * @return voting power amount\n     */\n    function convertTokensToVotingPower(uint256 amount) external pure override returns (uint256) {\n        return amount;\n    }\n}"
    },
    "contracts/lib/VotingPowerFormula.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nabstract contract VotingPowerFormula {\n   function convertTokensToVotingPower(uint256 amount) external view virtual returns (uint256);\n}"
    }
  }
}}