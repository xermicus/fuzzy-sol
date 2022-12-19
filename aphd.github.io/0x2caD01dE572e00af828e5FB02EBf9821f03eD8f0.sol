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
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "contracts/interfaces/IWETH.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity 0.8.7;\n\nimport {IERC20} from \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ninterface IWETH is IERC20 {\n    function deposit() external payable;\n\n    function withdraw(uint256 wad) external;\n}\n"
    },
    "contracts/interfaces/uniswap/IUniswapV2Router02.sol": {
      "content": "// \"SPDX-License-Identifier: GPL-3.0\"\npragma solidity 0.8.7;\n\ninterface IUniswapV2Router02 {\n    function swapExactETHForTokens(\n        uint256 minAmountOut,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external payable returns (uint256[] memory amounts);\n\n    function swapExactTokensForETH(\n        uint256 amountIn,\n        uint256 minAmountOut,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n\n    function swapExactTokensForTokens(\n        uint256 amountIn,\n        uint256 minAmountOut,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n\n    function swapTokensForExactETH(\n        uint256 amountOut,\n        uint256 amountInMax,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n\n    function getAmountsOut(uint256 amountIn, address[] calldata path)\n        external\n        view\n        returns (uint256[] memory amounts);\n\n    function getAmountsIn(uint256 amountOut, address[] calldata path)\n        external\n        view\n        returns (uint256[] memory amounts);\n\n    function factory() external pure returns (address);\n\n    // solhint-disable-next-line func-name-mixedcase\n    function WETH() external pure returns (address);\n}\n"
    },
    "contracts/resolvers/UniswapV2ResolverFlashbots.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.7;\n\nimport {IERC20} from \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport {IWETH} from \"../interfaces/IWETH.sol\";\nimport {IUniswapV2Router02} from \"../interfaces/uniswap/IUniswapV2Router02.sol\";\n\ncontract UniswapV2ResolverFlashbots {\n    // solhint-disable var-name-mixedcase\n    address public immutable WETH_ADDRESS;\n    address public constant ETH_ADDRESS =\n        address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);\n\n    IUniswapV2Router02 public UNI_ROUTER;\n\n    // solhint-enable var-name-mixedcase\n    constructor(address _weth, address _uniRouter) {\n        WETH_ADDRESS = _weth;\n        UNI_ROUTER = IUniswapV2Router02(_uniRouter);\n    }\n\n    /**\n     * @notice Check whether can execute an array of orders\n     * @param _totalFee all the fees the user pays. E.g. gelatoFee + minerBribe\n     * @return results - Whether each order can be executed or not\n     */\n    function multiCanExecute(\n        address[][] calldata _routerPaths,\n        uint256[] calldata _inputAmounts,\n        uint256[] calldata _minReturns,\n        uint256[] calldata _totalFee\n    ) external view returns (bool[] memory results) {\n        results = new bool[](_routerPaths.length);\n\n        for (uint256 i = 0; i < _routerPaths.length; i++) {\n            uint256 _inputAmount = _inputAmounts[i];\n\n            if (_routerPaths[i][0] == WETH_ADDRESS) {\n                results[i] = (_inputAmount <= _totalFee[i])\n                    ? false\n                    : (_getAmountOut(_inputAmount, _routerPaths[i]) >=\n                        _minReturns[i]);\n            } else if (\n                _routerPaths[i][_routerPaths[i].length - 1] == WETH_ADDRESS\n            ) {\n                uint256 bought = _getAmountOut(_inputAmount, _routerPaths[i]);\n\n                results[i] = (bought <= _totalFee[i])\n                    ? false\n                    : (bought >= _minReturns[i] + _totalFee[i]);\n            }\n        }\n    }\n\n    function _getAmountOut(uint256 _amountIn, address[] memory _path)\n        private\n        view\n        returns (uint256 amountOut)\n    {\n        uint256[] memory amountsOut = UNI_ROUTER.getAmountsOut(\n            _amountIn,\n            _path\n        );\n        amountOut = amountsOut[amountsOut.length - 1];\n    }\n}\n"
    }
  }
}}