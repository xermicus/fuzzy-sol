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
    "contracts/EdenNetworkManager.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./lib/Initializable.sol\";\n\n/**\n * @title EdenNetworkManager\n * @dev Handles updates for the EdenNetwork proxy + implementation\n */\ncontract EdenNetworkManager is Initializable {\n\n    /// @notice EdenNetworkManager admin\n    address public admin;\n\n    /// @notice EdenNetworkProxy address\n    address public edenNetworkProxy;\n\n    /// @notice Admin modifier\n    modifier onlyAdmin() {\n        require(msg.sender == admin, \"not admin\");\n        _;\n    }\n\n    /// @notice New admin event\n    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);\n\n    /// @notice New Eden Network proxy event\n    event EdenNetworkProxyChanged(address indexed oldEdenNetworkProxy, address indexed newEdenNetworkProxy);\n\n    /**\n     * @notice Construct new EdenNetworkManager contract, setting msg.sender as admin\n     */\n    constructor() {\n        admin = msg.sender;\n        emit AdminChanged(address(0), msg.sender);\n    }\n\n    /**\n     * @notice Initialize contract\n     * @param _edenNetworkProxy EdenNetwork proxy contract address\n     * @param _admin Admin address\n     */\n    function initialize(\n        address _edenNetworkProxy,\n        address _admin\n    ) external initializer onlyAdmin {\n        emit AdminChanged(admin, _admin);\n        admin = _admin;\n\n        edenNetworkProxy = _edenNetworkProxy;\n        emit EdenNetworkProxyChanged(address(0), _edenNetworkProxy);\n    }\n\n    /**\n     * @notice Set new admin for this contract\n     * @dev Can only be executed by admin\n     * @param newAdmin new admin address\n     */\n    function setAdmin(\n        address newAdmin\n    ) external onlyAdmin {\n        emit AdminChanged(admin, newAdmin);\n        admin = newAdmin;\n    }\n\n    /**\n     * @notice Set new Eden Network proxy contract\n     * @dev Can only be executed by admin\n     * @param newEdenNetworkProxy new Eden Network proxy address\n     */\n    function setEdenNetworkProxy(\n        address newEdenNetworkProxy\n    ) external onlyAdmin {\n        emit EdenNetworkProxyChanged(edenNetworkProxy, newEdenNetworkProxy);\n        edenNetworkProxy = newEdenNetworkProxy;\n    }\n\n    /**\n     * @notice Public getter for EdenNetwork Proxy implementation contract address\n     */\n    function getProxyImplementation() public view returns (address) {\n        // We need to manually run the static call since the getter cannot be flagged as view\n        // bytes4(keccak256(\"implementation()\")) == 0x5c60da1b\n        (bool success, bytes memory returndata) = edenNetworkProxy.staticcall(hex\"5c60da1b\");\n        require(success);\n        return abi.decode(returndata, (address));\n    }\n\n    /**\n     * @notice Public getter for EdenNetwork Proxy admin address\n     */\n    function getProxyAdmin() public view returns (address) {\n        // We need to manually run the static call since the getter cannot be flagged as view\n        // bytes4(keccak256(\"admin()\")) == 0xf851a440\n        (bool success, bytes memory returndata) = edenNetworkProxy.staticcall(hex\"f851a440\");\n        require(success);\n        return abi.decode(returndata, (address));\n    }\n\n    /**\n     * @notice Set new admin for EdenNetwork proxy contract\n     * @param newAdmin new admin address\n     */\n    function setProxyAdmin(\n        address newAdmin\n    ) external onlyAdmin {\n        // bytes4(keccak256(\"changeAdmin(address)\")) = 0x8f283970\n        (bool success, ) = edenNetworkProxy.call(abi.encodeWithSelector(hex\"8f283970\", newAdmin));\n        require(success, \"setProxyAdmin failed\");\n    }\n\n    /**\n     * @notice Set new implementation for EdenNetwork proxy contract\n     * @param newImplementation new implementation address\n     */\n    function upgrade(\n        address newImplementation\n    ) external onlyAdmin {\n        // bytes4(keccak256(\"upgradeTo(address)\")) = 0x3659cfe6\n        (bool success, ) = edenNetworkProxy.call(abi.encodeWithSelector(hex\"3659cfe6\", newImplementation));\n        require(success, \"upgrade failed\");\n    }\n\n    /**\n     * @notice Set new implementation for EdenNetwork proxy contract + call function after\n     * @param newImplementation new implementation address\n     * @param data Bytes-encoded function to call\n     */\n    function upgradeAndCall(\n        address newImplementation,\n        bytes memory data\n    ) external payable onlyAdmin {\n        // bytes4(keccak256(\"upgradeToAndCall(address,bytes)\")) = 0x4f1ef286\n        (bool success, ) = edenNetworkProxy.call{value: msg.value}(abi.encodeWithSelector(hex\"4f1ef286\", newImplementation, data));\n        require(success, \"upgradeAndCall failed\");\n    }\n}\n"
    },
    "contracts/lib/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n */\nabstract contract Initializable {\n    /**\n     * @dev Indicates that the contract has been initialized.\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice.\n     */\n    modifier initializer() {\n        require(_initializing || !_initialized, \"Initializable: contract is already initialized\");\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n}"
    }
  }
}}