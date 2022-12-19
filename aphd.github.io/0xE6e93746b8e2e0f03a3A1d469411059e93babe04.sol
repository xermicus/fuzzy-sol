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
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": false
      },
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
    "contracts/release/infrastructure/price-feeds/derivatives/IDerivativePriceFeed.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IDerivativePriceFeed Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Simple interface for derivative price source oracle implementations\ninterface IDerivativePriceFeed {\n    function calcUnderlyingValues(address, uint256)\n        external\n        returns (address[] memory, uint256[] memory);\n\n    function isSupportedAsset(address) external view returns (bool);\n}\n"
    },
    "contracts/release/infrastructure/price-feeds/derivatives/feeds/RevertingPriceFeed.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../IDerivativePriceFeed.sol\";\n\n/// @title RevertingPriceFeed Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Price feed that always reverts on value conversion\n/// @dev Used purely for extraordinary circumstances where we want to prevent value calculations,\n/// while allowing an asset to continue to be in the asset universe\ncontract RevertingPriceFeed is IDerivativePriceFeed {\n    /// @notice Converts a given amount of a derivative to its underlying asset values\n    function calcUnderlyingValues(address, uint256)\n        external\n        override\n        returns (address[] memory, uint256[] memory)\n    {\n        revert(\"calcUnderlyingValues: RevertingPriceFeed\");\n    }\n\n    /// @notice Checks whether an asset is a supported primitive of the price feed\n    /// @return isSupported_ True if the asset is a supported primitive\n    function isSupportedAsset(address) public view override returns (bool isSupported_) {\n        return true;\n    }\n}\n"
    }
  }
}}