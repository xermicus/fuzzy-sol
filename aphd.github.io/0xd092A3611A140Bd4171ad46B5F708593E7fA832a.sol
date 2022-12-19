{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
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
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface AggregatorInterface {\n  function latestAnswer()\n    external\n    view\n    returns (\n      int256\n    );\n  \n  function latestTimestamp()\n    external\n    view\n    returns (\n      uint256\n    );\n\n  function latestRound()\n    external\n    view\n    returns (\n      uint256\n    );\n\n  function getAnswer(\n    uint256 roundId\n  )\n    external\n    view\n    returns (\n      int256\n    );\n\n  function getTimestamp(\n    uint256 roundId\n  )\n    external\n    view\n    returns (\n      uint256\n    );\n\n  event AnswerUpdated(\n    int256 indexed current,\n    uint256 indexed roundId,\n    uint256 updatedAt\n  );\n\n  event NewRound(\n    uint256 indexed roundId,\n    address indexed startedBy,\n    uint256 startedAt\n  );\n}\n"
    },
    "contracts/oracle/ChainlinkPriceOracle.sol": {
      "content": "// Copyright 2021 Cartesi Pte. Ltd.\n\n// SPDX-License-Identifier: Apache-2.0\n// Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use\n// this file except in compliance with the License. You may obtain a copy of the\n// License at http://www.apache.org/licenses/LICENSE-2.0\n\n// Unless required by applicable law or agreed to in writing, software distributed\n// under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR\n// CONDITIONS OF ANY KIND, either express or implied. See the License for the\n// specific language governing permissions and limitations under the License.\n\npragma solidity ^0.8.0;\n\nimport \"@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol\";\nimport \"./PriceOracle.sol\";\n\ncontract ChainlinkPriceOracle is PriceOracle {\n    AggregatorInterface public immutable oracle;\n\n    constructor(address _oracle) {\n        oracle = AggregatorInterface(_oracle);\n    }\n\n    /// @notice Returns latest ETH/CTSI price\n    /// @return value of CTSI price in ETH\n    function getPrice() external view override returns (uint256) {\n        // get gas price from chainlink oracle\n        // https://data.chain.link/ethereum/mainnet/crypto-eth/ctsi-eth\n        return uint256(oracle.latestAnswer());\n    }\n}\n"
    },
    "contracts/oracle/PriceOracle.sol": {
      "content": "// Copyright 2021 Cartesi Pte. Ltd.\n\n// SPDX-License-Identifier: Apache-2.0\n// Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use\n// this file except in compliance with the License. You may obtain a copy of the\n// License at http://www.apache.org/licenses/LICENSE-2.0\n\n// Unless required by applicable law or agreed to in writing, software distributed\n// under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR\n// CONDITIONS OF ANY KIND, either express or implied. See the License for the\n// specific language governing permissions and limitations under the License.\n\n/// @title Interface staking contract\npragma solidity >=0.5.0 <0.9.0;\n\ninterface PriceOracle {\n    /// @notice Returns price of CTSI in ETH\n    /// @return value of 1 ETH in CTSI\n    function getPrice() external view returns (uint256);\n}\n"
    }
  }
}}