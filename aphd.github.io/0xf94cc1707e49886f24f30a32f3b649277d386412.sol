{{
  "language": "Solidity",
  "sources": {
    "./contracts/Migrations.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.4.22 <0.9.0;\n\ncontract Migrations {\n  address public owner = msg.sender;\n  uint public last_completed_migration;\n\n  modifier restricted() {\n    require(\n      msg.sender == owner,\n      \"This function is restricted to the contract's owner\"\n    );\n    _;\n  }\n\n  function setCompleted(uint completed) external restricted {\n    last_completed_migration = completed;\n  }\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}