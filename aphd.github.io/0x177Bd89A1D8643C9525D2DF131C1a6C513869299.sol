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
      "runs": 2000
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
    "contracts/interfaces/services/module/ISwapModule.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\ninterface ISwapModule {\n    function swap(address[] memory _swapActions, bytes[] memory _swapDatas)\n        external;\n}\n"
    },
    "contracts/lib/GelatoBytes.sol": {
      "content": "// \"SPDX-License-Identifier: UNLICENSED\"\npragma solidity 0.8.7;\n\nlibrary GelatoBytes {\n    function calldataSliceSelector(bytes calldata _bytes)\n        internal\n        pure\n        returns (bytes4 selector)\n    {\n        selector =\n            _bytes[0] |\n            (bytes4(_bytes[1]) >> 8) |\n            (bytes4(_bytes[2]) >> 16) |\n            (bytes4(_bytes[3]) >> 24);\n    }\n\n    function memorySliceSelector(bytes memory _bytes)\n        internal\n        pure\n        returns (bytes4 selector)\n    {\n        selector =\n            _bytes[0] |\n            (bytes4(_bytes[1]) >> 8) |\n            (bytes4(_bytes[2]) >> 16) |\n            (bytes4(_bytes[3]) >> 24);\n    }\n\n    function revertWithError(bytes memory _bytes, string memory _tracingInfo)\n        internal\n        pure\n    {\n        // 68: 32-location, 32-length, 4-ErrorSelector, UTF-8 err\n        if (_bytes.length % 32 == 4) {\n            bytes4 selector;\n            assembly {\n                selector := mload(add(0x20, _bytes))\n            }\n            if (selector == 0x08c379a0) {\n                // Function selector for Error(string)\n                assembly {\n                    _bytes := add(_bytes, 68)\n                }\n                revert(string(abi.encodePacked(_tracingInfo, string(_bytes))));\n            } else {\n                revert(\n                    string(abi.encodePacked(_tracingInfo, \"NoErrorSelector\"))\n                );\n            }\n        } else {\n            revert(\n                string(abi.encodePacked(_tracingInfo, \"UnexpectedReturndata\"))\n            );\n        }\n    }\n\n    function returnError(bytes memory _bytes, string memory _tracingInfo)\n        internal\n        pure\n        returns (string memory)\n    {\n        // 68: 32-location, 32-length, 4-ErrorSelector, UTF-8 err\n        if (_bytes.length % 32 == 4) {\n            bytes4 selector;\n            assembly {\n                selector := mload(add(0x20, _bytes))\n            }\n            if (selector == 0x08c379a0) {\n                // Function selector for Error(string)\n                assembly {\n                    _bytes := add(_bytes, 68)\n                }\n                return string(abi.encodePacked(_tracingInfo, string(_bytes)));\n            } else {\n                return\n                    string(abi.encodePacked(_tracingInfo, \"NoErrorSelector\"));\n            }\n        } else {\n            return\n                string(abi.encodePacked(_tracingInfo, \"UnexpectedReturndata\"));\n        }\n    }\n}\n"
    },
    "contracts/services/aave/module/SwapModule.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\nimport {ISwapModule} from \"../../../interfaces/services/module/ISwapModule.sol\";\nimport {GelatoBytes} from \"../../../lib/GelatoBytes.sol\";\n\ncontract SwapModule is ISwapModule {\n    function swap(address[] memory _swapActions, bytes[] memory _swapDatas)\n        external\n        override\n    {\n        require(\n            _swapActions.length == _swapDatas.length,\n            \"SwapModule.swap: actions length != datas length.\"\n        );\n\n        for (uint256 i; i < _swapActions.length; i++) {\n            {\n                (bool success, bytes memory returnsData) = _swapActions[i].call(\n                    _swapDatas[i]\n                );\n                if (!success)\n                    GelatoBytes.revertWithError(\n                        returnsData,\n                        \"SwapModule.swap: \"\n                    );\n            }\n        }\n    }\n}\n"
    }
  }
}}