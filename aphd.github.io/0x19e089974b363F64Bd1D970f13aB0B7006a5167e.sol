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
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "@openzeppelin/contracts/utils/math/Math.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Standard math utilities missing in the Solidity language.\n */\nlibrary Math {\n    /**\n     * @dev Returns the largest of two numbers.\n     */\n    function max(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a >= b ? a : b;\n    }\n\n    /**\n     * @dev Returns the smallest of two numbers.\n     */\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a < b ? a : b;\n    }\n\n    /**\n     * @dev Returns the average of two numbers. The result is rounded towards\n     * zero.\n     */\n    function average(uint256 a, uint256 b) internal pure returns (uint256) {\n        // (a + b) / 2 can overflow, so we distribute.\n        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);\n    }\n\n    /**\n     * @dev Returns the ceiling of the division of two numbers.\n     *\n     * This differs from standard division with `/` in that it rounds up instead\n     * of rounding down.\n     */\n    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {\n        // (a + b - 1) / b can overflow on addition, so we distribute.\n        return a / b + (a % b == 0 ? 0 : 1);\n    }\n}\n"
    },
    "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.7.5;\npragma abicoder v2;\n\n/// @title Quoter Interface\n/// @notice Supports quoting the calculated amounts from exact input or exact output swaps\n/// @dev These functions are not marked view because they rely on calling non-view functions and reverting\n/// to compute the result. They are also not gas efficient and should not be called on-chain.\ninterface IQuoter {\n    /// @notice Returns the amount out received for a given exact input swap without executing the swap\n    /// @param path The path of the swap, i.e. each token pair and the pool fee\n    /// @param amountIn The amount of the first token to swap\n    /// @return amountOut The amount of the last token that would be received\n    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);\n\n    /// @notice Returns the amount out received for a given exact input but for a swap of a single pool\n    /// @param tokenIn The token being swapped in\n    /// @param tokenOut The token being swapped out\n    /// @param fee The fee of the token pool to consider for the pair\n    /// @param amountIn The desired input amount\n    /// @param sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap\n    /// @return amountOut The amount of `tokenOut` that would be received\n    function quoteExactInputSingle(\n        address tokenIn,\n        address tokenOut,\n        uint24 fee,\n        uint256 amountIn,\n        uint160 sqrtPriceLimitX96\n    ) external returns (uint256 amountOut);\n\n    /// @notice Returns the amount in required for a given exact output swap without executing the swap\n    /// @param path The path of the swap, i.e. each token pair and the pool fee. Path must be provided in reverse order\n    /// @param amountOut The amount of the last token to receive\n    /// @return amountIn The amount of first token required to be paid\n    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);\n\n    /// @notice Returns the amount in required to receive the given exact output amount but for a swap of a single pool\n    /// @param tokenIn The token being swapped in\n    /// @param tokenOut The token being swapped out\n    /// @param fee The fee of the token pool to consider for the pair\n    /// @param amountOut The desired output amount\n    /// @param sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap\n    /// @return amountIn The amount required as the input for the swap in order to receive `amountOut`\n    function quoteExactOutputSingle(\n        address tokenIn,\n        address tokenOut,\n        uint24 fee,\n        uint256 amountOut,\n        uint160 sqrtPriceLimitX96\n    ) external returns (uint256 amountIn);\n}\n"
    },
    "contracts/constants/CAaveServices.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\naddress constant GELATO = 0x3CACa7b48D0573D793d3b0279b5F0029180E83b6;\nstring constant OK = \"OK\";\n"
    },
    "contracts/constants/CUniswapV3.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\naddress constant SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;\naddress constant QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;\nuint24 constant LOW_FEES = 500;\nuint24 constant MEDIUM_FEES = 3000;\nuint24 constant HIGH_FEES = 10000;\n"
    },
    "contracts/lib/GelatoString.sol": {
      "content": "// \"SPDX-License-Identifier: UNLICENSED\"\npragma solidity 0.8.7;\n\nlibrary GelatoString {\n    function startsWithOK(string memory _str) internal pure returns (bool) {\n        if (\n            bytes(_str).length >= 2 &&\n            bytes(_str)[0] == \"O\" &&\n            bytes(_str)[1] == \"K\"\n        ) return true;\n        return false;\n    }\n\n    function revertWithInfo(string memory _error, string memory _tracingInfo)\n        internal\n        pure\n    {\n        revert(string(abi.encodePacked(_tracingInfo, _error)));\n    }\n\n    function prefix(string memory _second, string memory _first)\n        internal\n        pure\n        returns (string memory)\n    {\n        return string(abi.encodePacked(_first, _second));\n    }\n\n    function suffix(string memory _first, string memory _second)\n        internal\n        pure\n        returns (string memory)\n    {\n        return string(abi.encodePacked(_first, _second));\n    }\n}\n"
    },
    "contracts/services/aave/resolver/UniswapV3Resolver.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\nimport {GelatoString} from \"../../../lib/GelatoString.sol\";\nimport {UniswapV3Data, UniswapV3Result} from \"../../../structs/SUniswapV3.sol\";\nimport {IQuoter} from \"@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol\";\nimport {\n    QUOTER,\n    LOW_FEES,\n    MEDIUM_FEES,\n    HIGH_FEES\n} from \"../../../constants/CUniswapV3.sol\";\nimport {Math} from \"@openzeppelin/contracts/utils/math/Math.sol\";\nimport {OK} from \"../../../constants/CAaveServices.sol\";\n\ncontract UniswapV3Resolver {\n    using GelatoString for string;\n    using Math for uint256;\n\n    // should be called with callstatic of etherjs,\n    // because quoteExactInputSingle is not a view function.\n    function multicallGetAmountsOut(UniswapV3Data[] calldata datas_)\n        public\n        returns (UniswapV3Result[] memory results)\n    {\n        results = new UniswapV3Result[](datas_.length);\n\n        for (uint256 i = 0; i < datas_.length; i++) {\n            try this.getBestPool(datas_[i]) returns (\n                UniswapV3Result memory result\n            ) {\n                results[i] = result;\n            } catch Error(string memory error) {\n                results[i] = UniswapV3Result({\n                    id: datas_[i].id,\n                    amountOut: 0,\n                    fee: 0,\n                    message: error.prefix(\n                        \"UniswapV3Resolver.getBestPool failed:\"\n                    )\n                });\n            } catch {\n                results[i] = UniswapV3Result({\n                    id: datas_[i].id,\n                    amountOut: 0,\n                    fee: 0,\n                    message: \"UniswapV3Resolver.getBestPool failed:undefined\"\n                });\n            }\n        }\n    }\n\n    function getBestPool(UniswapV3Data memory data_)\n        public\n        returns (UniswapV3Result memory)\n    {\n        uint256 amountOut = _quoteExactInputSingle(data_, LOW_FEES);\n        uint24 fee = LOW_FEES;\n\n        uint256 amountOutMediumFee;\n        if (\n            (amountOutMediumFee = _quoteExactInputSingle(data_, MEDIUM_FEES)) >\n            amountOut\n        ) {\n            amountOut = amountOutMediumFee;\n            fee = MEDIUM_FEES;\n        }\n\n        uint256 amountOutHighFee;\n        if (\n            (amountOutHighFee = _quoteExactInputSingle(data_, HIGH_FEES)) >\n            amountOut\n        ) {\n            amountOut = amountOutHighFee;\n            fee = HIGH_FEES;\n        }\n\n        return\n            UniswapV3Result({\n                id: data_.id,\n                amountOut: amountOut,\n                fee: fee,\n                message: OK\n            });\n    }\n\n    function _quoteExactInputSingle(UniswapV3Data memory data_, uint24 fee_)\n        internal\n        returns (uint256)\n    {\n        return\n            IQuoter(QUOTER).quoteExactInputSingle(\n                data_.tokenIn,\n                data_.tokenOut,\n                fee_,\n                data_.amountIn,\n                0\n            );\n    }\n}\n"
    },
    "contracts/structs/SUniswapV3.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\nstruct UniswapV3Result {\n    bytes32 id;\n    uint256 amountOut;\n    uint24 fee;\n    string message;\n}\n\nstruct UniswapV3Data {\n    bytes32 id;\n    address tokenIn;\n    address tokenOut;\n    uint256 amountIn;\n}\n"
    }
  }
}}