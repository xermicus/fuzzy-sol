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
      "runs": 200
    },
    "remappings": [],
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
  },
  "sources": {
    "contracts/governance/Timelock.sol": {
      "content": "// SPDX-License-Identifier: BSD-3-Clause\npragma solidity ^0.8.6;\n\n// solhint-disable private-vars-leading-underscore\ncontract Timelock {\n  event NewAdmin(address indexed newAdmin);\n  event NewPendingAdmin(address indexed newPendingAdmin);\n  event NewDelay(uint256 indexed newDelay);\n  event CancelTransaction(\n    bytes32 indexed txHash,\n    address indexed target,\n    uint256 value,\n    string signature,\n    bytes data,\n    uint256 eta\n  );\n  event ExecuteTransaction(\n    bytes32 indexed txHash,\n    address indexed target,\n    uint256 value,\n    string signature,\n    bytes data,\n    uint256 eta\n  );\n  event QueueTransaction(\n    bytes32 indexed txHash,\n    address indexed target,\n    uint256 value,\n    string signature,\n    bytes data,\n    uint256 eta\n  );\n\n  uint256 public constant GRACE_PERIOD = 14 days;\n  uint256 public constant MINIMUM_DELAY = 2 days;\n  uint256 public constant MAXIMUM_DELAY = 30 days;\n\n  address public admin;\n  address public pendingAdmin;\n  uint256 public delay;\n\n  mapping(bytes32 => bool) public queuedTransactions;\n\n  constructor(address admin_, uint256 delay_) {\n    require(delay_ >= MINIMUM_DELAY, \"Timelock::constructor: Delay must exceed minimum delay.\");\n    require(delay_ <= MAXIMUM_DELAY, \"Timelock::setDelay: Delay must not exceed maximum delay.\");\n\n    admin = admin_;\n    delay = delay_;\n  }\n\n  // solhint-disable-next-line no-empty-blocks\n  receive() external payable {}\n\n  function setDelay(uint256 delay_) public {\n    require(msg.sender == address(this), \"Timelock::setDelay: Call must come from Timelock.\");\n    require(delay_ >= MINIMUM_DELAY, \"Timelock::setDelay: Delay must exceed minimum delay.\");\n    require(delay_ <= MAXIMUM_DELAY, \"Timelock::setDelay: Delay must not exceed maximum delay.\");\n    delay = delay_;\n\n    emit NewDelay(delay);\n  }\n\n  function acceptAdmin() public {\n    require(msg.sender == pendingAdmin, \"Timelock::acceptAdmin: Call must come from pendingAdmin.\");\n    admin = msg.sender;\n    pendingAdmin = address(0);\n\n    emit NewAdmin(admin);\n  }\n\n  function setPendingAdmin(address pendingAdmin_) public {\n    require(msg.sender == address(this), \"Timelock::setPendingAdmin: Call must come from Timelock.\");\n    pendingAdmin = pendingAdmin_;\n\n    emit NewPendingAdmin(pendingAdmin);\n  }\n\n  function queueTransaction(\n    address target,\n    uint256 value,\n    string memory signature,\n    bytes memory data,\n    uint256 eta\n  ) public returns (bytes32) {\n    require(msg.sender == admin, \"Timelock::queueTransaction: Call must come from admin.\");\n    require(\n      eta >= getBlockTimestamp() + delay,\n      \"Timelock::queueTransaction: Estimated execution block must satisfy delay.\"\n    );\n\n    bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));\n    queuedTransactions[txHash] = true;\n\n    emit QueueTransaction(txHash, target, value, signature, data, eta);\n    return txHash;\n  }\n\n  function cancelTransaction(\n    address target,\n    uint256 value,\n    string memory signature,\n    bytes memory data,\n    uint256 eta\n  ) public {\n    require(msg.sender == admin, \"Timelock::cancelTransaction: Call must come from admin.\");\n\n    bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));\n    queuedTransactions[txHash] = false;\n\n    emit CancelTransaction(txHash, target, value, signature, data, eta);\n  }\n\n  function executeTransaction(\n    address target,\n    uint256 value,\n    string memory signature,\n    bytes memory data,\n    uint256 eta\n  ) public payable returns (bytes memory) {\n    require(msg.sender == admin, \"Timelock::executeTransaction: Call must come from admin.\");\n\n    bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));\n    require(queuedTransactions[txHash], \"Timelock::executeTransaction: Transaction hasn't been queued.\");\n    require(getBlockTimestamp() >= eta, \"Timelock::executeTransaction: Transaction hasn't surpassed time lock.\");\n    require(getBlockTimestamp() <= eta + GRACE_PERIOD, \"Timelock::executeTransaction: Transaction is stale.\");\n\n    queuedTransactions[txHash] = false;\n\n    bytes memory callData;\n\n    if (bytes(signature).length == 0) {\n      callData = data;\n    } else {\n      callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);\n    }\n\n    // solhint-disable-next-line avoid-low-level-calls\n    (bool success, bytes memory returnData) = target.call{value: value}(callData);\n    require(success, \"Timelock::executeTransaction: Transaction execution reverted.\");\n\n    emit ExecuteTransaction(txHash, target, value, signature, data, eta);\n\n    return returnData;\n  }\n\n  function getBlockTimestamp() internal view returns (uint256) {\n    // solhint-disable-next-line not-rely-on-time\n    return block.timestamp;\n  }\n}\n"
    }
  }
}}