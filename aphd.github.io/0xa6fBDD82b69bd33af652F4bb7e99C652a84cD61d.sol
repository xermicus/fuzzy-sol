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
    "contracts/abstract/Lockable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.6;\n\nimport { Ownable } from \"./Ownable.sol\";\n\nabstract contract LockableData {\n    bool public locked;\n}\n\nabstract contract Lockable is LockableData, Ownable {\n    /**\n     * @dev Locks functions with whenNotLocked modifier\n     */\n    function lock() external onlyOwner {\n        locked = true;\n    }\n\n    /**\n     * @dev Throws if called after it was locked.\n     */\n    modifier whenNotLocked {\n        require(!locked, \"Lockable: locked\");\n        _;\n    }\n}\n"
    },
    "contracts/abstract/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.6;\n\nabstract contract OwnableData {\n    address public owner;\n    address public pendingOwner;\n}\n\nabstract contract Ownable is OwnableData {\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev `owner` defaults to msg.sender on construction.\n     */\n    constructor() {\n        _setOwner(msg.sender);\n    }\n\n    /**\n     * @dev Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.\n     *      Can only be invoked by the current `owner`.\n     * @param _newOwner Address of the new owner.\n     * @param _direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.\n     */\n    function transferOwnership(address _newOwner, bool _direct) external onlyOwner {\n        if (_direct) {\n            require(_newOwner != address(0), \"zero address\");\n\n            emit OwnershipTransferred(owner, _newOwner);\n            owner = _newOwner;\n            pendingOwner = address(0);\n        } else {\n            pendingOwner = _newOwner;\n        }\n    }\n\n    /**\n     * @dev Needs to be called by `pendingOwner` to claim ownership.\n     */\n    function claimOwnership() external {\n        address _pendingOwner = pendingOwner;\n        require(msg.sender == _pendingOwner, \"caller != pending owner\");\n\n        emit OwnershipTransferred(owner, _pendingOwner);\n        owner = _pendingOwner;\n        pendingOwner = address(0);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the Owner.\n     */\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"caller is not the owner\");\n        _;\n    }\n\n    function _setOwner(address newOwner) internal {\n        address oldOwner = owner;\n        owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "contracts/crosssale/CommunityPolygon.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.6;\n\nimport { CrossSaleData } from \"./CrossSaleData.sol\";\n\ncontract CommunityPolygon is CrossSaleData {}\n"
    },
    "contracts/crosssale/CrossSaleData.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.6;\n\nimport { Ownable } from \"../abstract/Ownable.sol\";\nimport { Lockable } from \"../abstract/Lockable.sol\";\n\ncontract CrossSaleData is Ownable, Lockable {\n    mapping(address => uint256) public balanceOf;\n\n    function addUser(address user, uint256 amount) external onlyOwner whenNotLocked {\n        balanceOf[user] = amount;\n    }\n\n    function massAddUsers(address[] calldata user, uint256[] calldata amount) external onlyOwner whenNotLocked {\n        uint256 len = user.length;\n        require(len == amount.length, \"Data size mismatch\");\n        uint256 i;\n        for (i; i < len; i++) {\n            balanceOf[user[i]] = amount[i];\n        }\n    }\n}\n"
    }
  }
}}