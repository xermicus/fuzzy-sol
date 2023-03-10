{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 800
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
    "contracts/AdapterLens.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.7.6;\npragma abicoder v2;\n\nimport \"./interfaces/IProtocolAdapter.sol\";\nimport \"./interfaces/IAdapterRegistry.sol\";\n\n\n\ncontract AdapterLens {\n  IAdapterRegistry internal registry = IAdapterRegistry(0x5F2945604013Ee9f80aE2eDDb384462B681859C4);\n\n  function getSupportedProtocols(address token) external view returns (string[] memory protocolNames) {\n    address[] memory adapters = registry.getAdaptersList(token);\n    protocolNames = new string[](adapters.length);\n    for (uint256 i; i < adapters.length; i++) {\n      protocolNames[i] = IProtocolAdapter(registry.getProtocolForTokenAdapter(adapters[i])).protocol();\n    }\n  }\n}"
    },
    "contracts/interfaces/IAdapterRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.7.6;\n\n\ninterface IAdapterRegistry {\n/* ========== Events ========== */\n\n  event ProtocolAdapterAdded(uint256 protocolId, address protocolAdapter);\n\n  event ProtocolAdapterRemoved(uint256 protocolId);\n\n  event TokenAdapterAdded(address adapter, uint256 protocolId, address underlying, address wrapper);\n\n  event TokenAdapterRemoved(address adapter, uint256 protocolId, address underlying, address wrapper);\n\n  event TokenSupportAdded(address underlying);\n\n  event TokenSupportRemoved(address underlying);\n\n  event VaultFactoryAdded(address factory);\n\n  event VaultFactoryRemoved(address factory);\n\n  event VaultAdded(address underlying, address vault);\n\n  event VaultRemoved(address underlying, address vault);\n\n/* ========== Structs ========== */\n\n  struct TokenAdapter {\n    address adapter;\n    uint96 protocolId;\n  }\n\n/* ========== Storage ========== */\n\n  function protocolsCount() external view returns (uint256);\n\n  function protocolAdapters(uint256 id) external view returns (address protocolAdapter);\n\n  function protocolAdapterIds(address protocolAdapter) external view returns (uint256 id);\n\n  function vaultsByUnderlying(address underlying) external view returns (address vault);\n\n  function approvedVaultFactories(address factory) external view returns (bool approved);\n\n/* ========== Vault Factory Management ========== */\n\n  function addVaultFactory(address _factory) external;\n\n  function removeVaultFactory(address _factory) external;\n\n/* ========== Vault Management ========== */\n\n  function addVault(address vault) external;\n\n  function removeVault(address vault) external;\n\n/* ========== Protocol Adapter Management ========== */\n\n  function addProtocolAdapter(address protocolAdapter) external returns (uint256 id);\n\n  function removeProtocolAdapter(address protocolAdapter) external;\n\n/* ========== Token Adapter Management ========== */\n\n  function addTokenAdapter(address adapter) external;\n\n  function addTokenAdapters(address[] calldata adapters) external;\n\n  function removeTokenAdapter(address adapter) external;\n\n/* ========== Vault Queries ========== */\n\n  function getVaultsList() external view returns (address[] memory);\n\n  function haveVaultFor(address underlying) external view returns (bool);\n\n/* ========== Protocol Queries ========== */\n\n  function getProtocolAdaptersAndIds() external view returns (address[] memory adapters, uint256[] memory ids);\n\n  function getProtocolMetadata(uint256 id) external view returns (address protocolAdapter, string memory name);\n\n  function getProtocolForTokenAdapter(address adapter) external view returns (address protocolAdapter);\n\n/* ========== Supported Token Queries ========== */\n\n  function isSupported(address underlying) external view returns (bool);\n\n  function getSupportedTokens() external view returns (address[] memory list);\n\n/* ========== Token Adapter Queries ========== */\n\n  function isApprovedAdapter(address adapter) external view returns (bool);\n\n  function getAdaptersList(address underlying) external view returns (address[] memory list);\n\n  function getAdapterForWrapperToken(address wrapperToken) external view returns (address);\n\n  function getAdaptersCount(address underlying) external view returns (uint256);\n\n  function getAdaptersSortedByAPR(address underlying)\n    external\n    view\n    returns (address[] memory adapters, uint256[] memory aprs);\n\n  function getAdaptersSortedByAPRWithDeposit(\n    address underlying,\n    uint256 deposit,\n    address excludingAdapter\n  )\n    external\n    view\n    returns (address[] memory adapters, uint256[] memory aprs);\n\n  function getAdapterWithHighestAPR(address underlying) external view returns (address adapter, uint256 apr);\n\n  function getAdapterWithHighestAPRForDeposit(\n    address underlying,\n    uint256 deposit,\n    address excludingAdapter\n  ) external view returns (address adapter, uint256 apr);\n}\n\n"
    },
    "contracts/interfaces/IProtocolAdapter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.5.10;\nimport \"./IAdapterRegistry.sol\";\n\n\ninterface IProtocolAdapter {\n  event MarketFrozen(address token);\n\n  event MarketUnfrozen(address token);\n\n  event AdapterFrozen(address adapter);\n\n  event AdapterUnfrozen(address adapter);\n\n  function registry() external view returns (IAdapterRegistry);\n\n  function frozenAdapters(uint256 index) external view returns (address);\n\n  function frozenTokens(uint256 index) external view returns (address);\n\n  function totalMapped() external view returns (uint256);\n\n  function protocol() external view returns (string memory);\n\n  function getUnmapped() external view returns (address[] memory tokens);\n\n  function getUnmappedUpTo(uint256 max) external view returns (address[] memory tokens);\n\n  function map(uint256 max) external;\n\n  function unfreezeAdapter(uint256 index) external;\n\n  function unfreezeToken(uint256 index) external;\n\n  function freezeAdapter(address adapter) external;\n}"
    }
  }
}}