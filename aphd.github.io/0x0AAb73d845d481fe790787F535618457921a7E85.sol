{{
  "language": "Solidity",
  "sources": {
    "/contracts/Migrations.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\n// Note: For some reason Migrations.sol needs to be in the root or they run everytime\n\ncontract Migrations {\n  address public owner;\n  uint public last_completed_migration;\n\n  modifier restricted() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  constructor() {\n    owner = msg.sender;\n  }\n\n  function setCompleted(uint completed) external restricted {\n    last_completed_migration = completed;\n  }\n\n  function upgrade(address newAddress) external restricted {\n    Migrations upgraded = Migrations(newAddress);\n    upgraded.setCompleted(last_completed_migration);\n  }\n}\n"
    }
  },
  "settings": {
    "remappings": [],
    "optimizer": {
      "enabled": true,
      "runs": 15000
    },
    "evmVersion": "istanbul",
    "libraries": {},
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