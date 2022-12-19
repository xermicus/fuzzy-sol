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
    "contracts/constants/CAaveServices.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\naddress constant GELATO = 0x3CACa7b48D0573D793d3b0279b5F0029180E83b6;\nstring constant OK = \"OK\";\n"
    },
    "contracts/constants/CUniswap.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\naddress constant UNISWAPV2ROUTER02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;\n"
    },
    "contracts/interfaces/uniswap/IUniswapV2Router02.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\ninterface IUniswapV2Router02 {\n    function getAmountsOut(uint256 amountIn, address[] memory path)\n        external\n        view\n        returns (uint256[] memory amounts);\n\n    function getAmountsIn(uint256 amountOut, address[] memory path)\n        external\n        view\n        returns (uint256[] memory amounts);\n\n    function getAmountOut(\n        uint256 amountIn,\n        uint256 reserveIn,\n        uint256 reserveOut\n    ) external pure returns (uint256 amountOut);\n\n    function getAmountIn(\n        uint256 amountOut,\n        uint256 reserveIn,\n        uint256 reserveOut\n    ) external pure returns (uint256 amountIn);\n\n    function swapExactTokensForTokens(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n}\n"
    },
    "contracts/lib/GelatoString.sol": {
      "content": "// \"SPDX-License-Identifier: UNLICENSED\"\npragma solidity 0.8.7;\n\nlibrary GelatoString {\n    function startsWithOK(string memory _str) internal pure returns (bool) {\n        if (\n            bytes(_str).length >= 2 &&\n            bytes(_str)[0] == \"O\" &&\n            bytes(_str)[1] == \"K\"\n        ) return true;\n        return false;\n    }\n\n    function revertWithInfo(string memory _error, string memory _tracingInfo)\n        internal\n        pure\n    {\n        revert(string(abi.encodePacked(_tracingInfo, _error)));\n    }\n\n    function prefix(string memory _second, string memory _first)\n        internal\n        pure\n        returns (string memory)\n    {\n        return string(abi.encodePacked(_first, _second));\n    }\n\n    function suffix(string memory _first, string memory _second)\n        internal\n        pure\n        returns (string memory)\n    {\n        return string(abi.encodePacked(_first, _second));\n    }\n}\n"
    },
    "contracts/services/aave/resolver/UniswapResolver.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\nimport {GelatoString} from \"../../../lib/GelatoString.sol\";\nimport {UniswapData, UniswapResult} from \"../../../structs/SUniswap.sol\";\nimport {\n    IUniswapV2Router02\n} from \"../../../interfaces/uniswap/IUniswapV2Router02.sol\";\nimport {UNISWAPV2ROUTER02} from \"../../../constants/CUniswap.sol\";\nimport {OK} from \"../../../constants/CAaveServices.sol\";\n\ncontract UniswapResolver {\n    using GelatoString for string;\n\n    function multicallGetAmounts(UniswapData[] memory _datas)\n        public\n        view\n        returns (UniswapResult[] memory)\n    {\n        UniswapResult[] memory results = new UniswapResult[](_datas.length);\n\n        for (uint256 i = 0; i < _datas.length; i++) {\n            try\n                IUniswapV2Router02(UNISWAPV2ROUTER02).getAmountsOut(\n                    _datas[i].amountIn,\n                    _datas[i].path\n                )\n            returns (uint256[] memory amounts) {\n                results[i] = UniswapResult({\n                    id: _datas[i].id,\n                    amountOut: amounts[_datas[i].path.length - 1],\n                    message: OK\n                });\n            } catch Error(string memory error) {\n                results[i] = UniswapResult({\n                    id: _datas[i].id,\n                    amountOut: 0,\n                    message: error.prefix(\n                        \"UniswapResolver.getAmountOut failed:\"\n                    )\n                });\n            } catch {\n                results[i] = UniswapResult({\n                    id: _datas[i].id,\n                    amountOut: 0,\n                    message: \"UniswapResolver.getAmountOut failed:undefined\"\n                });\n            }\n        }\n\n        return results;\n    }\n}\n"
    },
    "contracts/structs/SUniswap.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\nstruct UniswapResult {\n    bytes32 id;\n    uint256 amountOut;\n    string message;\n}\n\nstruct UniswapData {\n    bytes32 id;\n    uint256 amountIn;\n    address[] path;\n}\n"
    }
  }
}}