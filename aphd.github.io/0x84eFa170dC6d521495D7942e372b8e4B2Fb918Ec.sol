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
      "enabled": true,
      "runs": 100
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
    "contracts/bridge/BridgeUtils.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\n/*\n * Copyright 2021, Offchain Labs, Inc.\n *\n * Licensed under the Apache License, Version 2.0 (the \"License\");\n * you may not use this file except in compliance with the License.\n * You may obtain a copy of the License at\n *\n *    http://www.apache.org/licenses/LICENSE-2.0\n *\n * Unless required by applicable law or agreed to in writing, software\n * distributed under the License is distributed on an \"AS IS\" BASIS,\n * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n * See the License for the specific language governing permissions and\n * limitations under the License.\n */\n\npragma solidity ^0.6.11;\n\nimport \"./interfaces/IBridge.sol\";\nimport \"./interfaces/ISequencerInbox.sol\";\n\ncontract BridgeUtils {\n    function getCountsAndAccumulators(IBridge delayedBridge, ISequencerInbox sequencerInbox)\n        external\n        view\n        returns (uint256[2] memory counts, bytes32[2] memory accs)\n    {\n        uint256 delayedCount = delayedBridge.messageCount();\n        if (delayedCount > 0) {\n            counts[0] = delayedCount;\n            accs[0] = delayedBridge.inboxAccs(delayedCount - 1);\n        }\n        uint256 sequencerBatchCount = sequencerInbox.getInboxAccsLength();\n        if (sequencerBatchCount > 0) {\n            counts[1] = sequencerInbox.messageCount();\n            accs[1] = sequencerInbox.inboxAccs(sequencerBatchCount - 1);\n        }\n    }\n}\n"
    },
    "contracts/bridge/interfaces/IBridge.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\n/*\n * Copyright 2021, Offchain Labs, Inc.\n *\n * Licensed under the Apache License, Version 2.0 (the \"License\");\n * you may not use this file except in compliance with the License.\n * You may obtain a copy of the License at\n *\n *    http://www.apache.org/licenses/LICENSE-2.0\n *\n * Unless required by applicable law or agreed to in writing, software\n * distributed under the License is distributed on an \"AS IS\" BASIS,\n * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n * See the License for the specific language governing permissions and\n * limitations under the License.\n */\n\npragma solidity ^0.6.11;\n\ninterface IBridge {\n    event MessageDelivered(\n        uint256 indexed messageIndex,\n        bytes32 indexed beforeInboxAcc,\n        address inbox,\n        uint8 kind,\n        address sender,\n        bytes32 messageDataHash\n    );\n\n    function deliverMessageToInbox(\n        uint8 kind,\n        address sender,\n        bytes32 messageDataHash\n    ) external payable returns (uint256);\n\n    function executeCall(\n        address destAddr,\n        uint256 amount,\n        bytes calldata data\n    ) external returns (bool success, bytes memory returnData);\n\n    // These are only callable by the admin\n    function setInbox(address inbox, bool enabled) external;\n\n    function setOutbox(address inbox, bool enabled) external;\n\n    // View functions\n\n    function activeOutbox() external view returns (address);\n\n    function allowedInboxes(address inbox) external view returns (bool);\n\n    function allowedOutboxes(address outbox) external view returns (bool);\n\n    function inboxAccs(uint256 index) external view returns (bytes32);\n\n    function messageCount() external view returns (uint256);\n}\n"
    },
    "contracts/bridge/interfaces/ISequencerInbox.sol": {
      "content": "// SPDX-License-Identifier: Apache-2.0\n\n/*\n * Copyright 2021, Offchain Labs, Inc.\n *\n * Licensed under the Apache License, Version 2.0 (the \"License\");\n * you may not use this file except in compliance with the License.\n * You may obtain a copy of the License at\n *\n *    http://www.apache.org/licenses/LICENSE-2.0\n *\n * Unless required by applicable law or agreed to in writing, software\n * distributed under the License is distributed on an \"AS IS\" BASIS,\n * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n * See the License for the specific language governing permissions and\n * limitations under the License.\n */\n\npragma solidity ^0.6.11;\n\ninterface ISequencerInbox {\n    event SequencerBatchDelivered(\n        uint256 indexed firstMessageNum,\n        bytes32 indexed beforeAcc,\n        uint256 newMessageCount,\n        bytes32 afterAcc,\n        bytes transactions,\n        uint256[] lengths,\n        uint256[] sectionsMetadata,\n        uint256 seqBatchIndex,\n        address sequencer\n    );\n\n    event SequencerBatchDeliveredFromOrigin(\n        uint256 indexed firstMessageNum,\n        bytes32 indexed beforeAcc,\n        uint256 newMessageCount,\n        bytes32 afterAcc,\n        uint256 seqBatchIndex\n    );\n\n    event DelayedInboxForced(\n        uint256 indexed firstMessageNum,\n        bytes32 indexed beforeAcc,\n        uint256 newMessageCount,\n        uint256 totalDelayedMessagesRead,\n        bytes32[2] afterAccAndDelayed,\n        uint256 seqBatchIndex\n    );\n\n    event SequencerAddressUpdated(address newAddress);\n\n    function setSequencer(address newSequencer) external;\n\n    function messageCount() external view returns (uint256);\n\n    function maxDelayBlocks() external view returns (uint256);\n\n    function maxDelaySeconds() external view returns (uint256);\n\n    function inboxAccs(uint256 index) external view returns (bytes32);\n\n    function getInboxAccsLength() external view returns (uint256);\n\n    function proveBatchContainsSequenceNumber(bytes calldata proof, uint256 inboxCount)\n        external\n        view\n        returns (uint256, bytes32);\n}\n"
    }
  }
}}