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
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "contracts/TreasuryDAO.sol": {
      "content": "// contracts/utilities/TreasuryDAO.sol\n// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract TreasuryDAO {\n  string public name;\n\n  address public owner;\n  uint256 public totalShares;\n\n  address public changeDAO;\n  address public community;\n\n  address[] public tokens;\n  uint256 public totalFunds;\n\n  mapping(address => uint256) public shares;\n  uint256 public shareUnit;\n  uint256 public thumbs;\n  mapping(address => uint256) public lastShares;\n\n  constructor(string memory name_) {\n    name = name_;\n    owner = msg.sender;\n  }\n\n  modifier onlyOwner() {\n    require(msg.sender == owner, \"Permission denied\");\n    _;\n  }\n\n  function addShare(address account, uint256 share) internal {\n    require(account != address(0), \"Invalid account\");\n    require(shares[account] == 0, \"Share exists\");\n    totalShares += share;\n    shares[account] = share;\n    lastShares[account] = shareUnit;\n  }\n\n  function addShares(address[] memory accounts, uint256[] memory sharings) external onlyOwner {\n    require(accounts.length == sharings.length, \"Invalid counts\");\n    require(accounts.length < 256, \"Invalid length\");\n    for (uint8 i = 0; i < accounts.length; i++) {\n      addShare(accounts[i], sharings[i]);\n    }\n  }\n\n  function removeShare(address account) internal {\n    require(shares[account] > 0, \"Invalid share\");\n    uint256 share = shares[account];\n    delete shares[account];\n    totalShares -= share;\n    if (shareUnit > lastShares[account]) {\n      uint256 refund = (shareUnit - lastShares[account]) * share;\n      lastShares[account] = shareUnit;\n      addFund(refund);\n    }\n  }\n\n  function removeShares(address[] memory accounts) external onlyOwner {\n    require(accounts.length < 256, \"Invalid length\");\n    for (uint8 i = 0; i < accounts.length; i++) {\n      removeShare(accounts[i]);\n    }\n  }\n\n  function addFund(uint256 amount) internal {\n    require(totalShares > 0, \"No shares\");\n    totalFunds += amount;\n    uint256 newAmount = amount + thumbs;\n    uint256 newUnit = newAmount / totalShares;\n    shareUnit += newUnit;\n    thumbs = newAmount - (newUnit * totalShares);\n  }\n\n  function getAllocation(address account) public view returns (uint256 allocation) {\n    allocation = (shareUnit - lastShares[account]) * shares[account];\n  }\n\n  function withdraw() external {\n    uint256 allocation = getAllocation(msg.sender);\n    require(allocation > 0, \"Funds empty\");\n    lastShares[msg.sender] = shareUnit;\n    payable(msg.sender).transfer(allocation);\n  }\n\n  function raise() external payable {\n    addFund(msg.value);\n  }\n}\n"
    }
  }
}}