{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.8.4;\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}"},"IUniswapV2Router.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.8.4;\n\ninterface IUniswapV2Router {\n    function swapExactTokensForTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external returns (uint[] memory amounts);\n\n    function swapTokensForExactTokens(\n        uint amountOut,\n        uint amountInMax,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external returns (uint[] memory amounts);\n\n    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external\n        payable\n        returns (uint[] memory amounts);\n\n    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)\n        external\n        returns (uint[] memory amounts);\n\n    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external\n        returns (uint[] memory amounts);\n\n    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)\n        external\n        payable\n        returns (uint[] memory amounts);\n    \n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external;\n\n    function swapExactETHForTokensSupportingFeeOnTransferTokens(\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external payable;\n    \n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external;\n\n    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);\n    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);\n    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);\n    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);\n    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);\n}"},"IWETH.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.8.4;\nimport \"./IERC20.sol\";\n\ninterface IWETH is IERC20 {\n    function deposit() external payable;\n}"},"matrEXRouterV2.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.8.4;\nimport \"./Ownable.sol\";\nimport \"./IUniswapV2Router.sol\";\nimport \"./IERC20.sol\";\nimport \"./IWETH.sol\";\n\ncontract matrEXRouterV2 is Ownable, IUniswapV2Router{\n    /**\n    * @dev Event emitted when the charity fee is taken\n    * @param from: The user it is taken from\n    * @param token: The token that was taken from the user\n    * @param amount: The amount of the token taken for charity\n    */\n    event feeTaken(address from, IERC20 token, uint256 amount);\n\n    /**\n    * @dev Event emitted when the charity fee is taken (in ETH)\n    * @param from: The user it was taken from\n    * @param amount: The amount of ETH taken in wei\n    */\n    event feeTakenInETH(address from, uint256 amount);\n\n    /**\n    * @dev Event emmited when a token is approved for trade for the first\n    * time on Uniswap (check takeFeeAndApprove())\n    * @param token: The tokens that was approved for trade\n    */\n    event approvedForTrade(IERC20 token);\n\n    /**\n    * @dev \n    * _charityFee: The % that is taken from each swap that gets sent to charity\n    * _charityAddress: The address that the charity funds get sent to\n    * _uniswapV2Router: Uniswap router that all swaps go through\n    */\n    uint256 private _charityFee;\n    address private _charityAddress;\n    address private _WETH;\n    IUniswapV2Router private _uniswapV2Router;\n\n    /**\n    * @dev Sets the Uniswap Router, Charity Fee and Charity Address \n    */\n    constructor(){\n        _uniswapV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);\n        _charityFee = 20;\n        _charityAddress = address(0x830be1dba01bfF12C706b967AcDeCd2fDEa48990);\n        _WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\n    }\n\n    /**\n    * @dev Calculates the fee and takes it, transfers the fee to the charity\n    * address and the remains to this contract.\n    * emits feeTaken()\n    * Then, it checks if there is enough approved for the swap, if not it\n    * approves it to the uniswap contract. Emits approvedForTrade if so.\n    * @param user: The payer\n    * @param token: The token that will be swapped and the fee will be paid\n    * in\n    * @param totalAmount: The total amount of tokens that will be swapped, will\n    * be used to calculate how much the fee will be\n    */\n    function takeFeeAndApprove(address user, IERC20 token, uint256 totalAmount) internal returns (uint256){\n        uint256 _feeTaken = (totalAmount * _charityFee) / 10000;\n        token.transferFrom(user, address(this), totalAmount - _feeTaken);\n        token.transferFrom(user, _charityAddress, _feeTaken);\n        if (token.allowance(address(this), address(_uniswapV2Router)) \u003c totalAmount){\n            token.approve(address(_uniswapV2Router), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);\n            emit approvedForTrade(token);\n        }\n        emit feeTaken(user, token, _feeTaken);\n        return totalAmount -= _feeTaken;\n    }\n    \n    /**\n    * @dev Calculates the fee and takes it, holds the fee in the contract and \n    * can be sent to charity when someone calls withdraw()\n    * This makes sure:\n    * 1. That the user doesn\u0027t spend extra gas for an ERC20 transfer + \n    * wrap\n    * 2. That funds can be safely transfered to a contract\n    * emits feeTakenInETH()\n    * @param totalAmount: The total amount of tokens that will be swapped, will\n    * be used to calculate how much the fee will be\n    */\n    function takeFeeETH(uint256 totalAmount) internal returns (uint256){\n        uint256 fee = (totalAmount * _charityFee) / 10000;\n        emit feeTakenInETH(_msgSender(), fee);\n        return totalAmount - fee;\n    }\n    \n    /**\n    * @dev The functions below are all the same as the Uniswap contract but\n    * they call takeFeeAndApprove() or takeFeeETH() (See the functions above)\n    * and deduct the fee from the amount that will be traded.\n    */\n    function swapExactTokensForTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external override returns (uint[] memory amounts){\n        uint256 newAmount = takeFeeAndApprove(_msgSender(), IERC20(path[0]), amountIn);\n        return _uniswapV2Router.swapExactTokensForTokens(newAmount, amountOutMin, path, to,deadline);\n    }\n    \n    function swapTokensForExactTokens(\n        uint amountOut,\n        uint amountInMax,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external override returns (uint[] memory amounts){\n        uint256 newAmount = takeFeeAndApprove(_msgSender(), IERC20(path[0]), amountOut);\n        return _uniswapV2Router.swapTokensForExactTokens(newAmount, amountInMax, path, to,deadline);\n        \n    }\n    \n    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external\n        payable\n        override\n        returns (uint[] memory amounts){\n            uint256 newValue = takeFeeETH(msg.value);\n            return _uniswapV2Router.swapExactETHForTokens{value: newValue}(amountOutMin, path, to, deadline);\n        }\n        \n        \n    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)\n        external override\n        returns (uint[] memory amounts){\n            uint256 newAmount = takeFeeAndApprove(_msgSender(), IERC20(path[0]), amountOut);\n            return _uniswapV2Router.swapTokensForExactETH(newAmount, amountInMax, path, to, deadline);\n        }\n        \n    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external override\n        returns (uint[] memory amounts) {\n            uint256 newAmount = takeFeeAndApprove(_msgSender(), IERC20(path[0]), amountIn);\n            return _uniswapV2Router.swapExactTokensForETH(newAmount, amountOutMin, path, to, deadline);\n        }\n    \n    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)\n        external\n        payable override\n        returns (uint[] memory amounts){\n            uint256 newValue = takeFeeETH(msg.value);\n            return _uniswapV2Router.swapETHForExactTokens{value: newValue}(amountOut, path, to, deadline);\n        }\n    \n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external override {\n        uint256 newAmount = takeFeeAndApprove(_msgSender(), IERC20(path[0]), amountIn);\n        return _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(newAmount, amountOutMin, path, to, deadline);\n    }\n    \n    function swapExactETHForTokensSupportingFeeOnTransferTokens(\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external override payable{\n        uint256 newValue = takeFeeETH(msg.value);\n        return _uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: newValue}(amountOutMin, path, to, deadline);\n    }\n    \n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external override {\n        uint256 newAmount = takeFeeAndApprove(_msgSender(), IERC20(path[0]), amountIn);\n        return _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(newAmount, amountOutMin, path, to, deadline);\n    }\n\n    /**\n    * @dev Same as Uniswap\n    */\n    function quote(uint amountA, uint reserveA, uint reserveB) external override pure returns (uint amountB){\n        require(amountA \u003e 0, \u0027UniswapV2Library: INSUFFICIENT_AMOUNT\u0027);\n        require(reserveA \u003e 0 \u0026\u0026 reserveB \u003e 0, \u0027UniswapV2Library: INSUFFICIENT_LIQUIDITY\u0027);\n        amountB = (amountA * reserveB) / reserveA;\n    }\n    \n    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure override returns (uint amountOut){\n        require(amountIn \u003e 0, \u0027UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT\u0027);\n        require(reserveIn \u003e 0 \u0026\u0026 reserveOut \u003e 0, \u0027UniswapV2Library: INSUFFICIENT_LIQUIDITY\u0027);\n        uint amountInWithFee = amountIn * 997;\n        uint numerator = amountInWithFee * reserveOut;\n        uint denominator = (reserveIn * 1000) + amountInWithFee;\n        amountOut = numerator / denominator;\n    }\n    \n    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external override pure returns (uint amountIn){\n        require(amountOut \u003e 0, \u0027UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT\u0027);\n        require(reserveIn \u003e 0 \u0026\u0026 reserveOut \u003e 0, \u0027UniswapV2Library: INSUFFICIENT_LIQUIDITY\u0027);\n        uint numerator = (reserveIn * amountOut) * 1000;\n        uint denominator = (reserveOut - amountOut) * 997;\n        amountIn = (numerator / denominator) + 1;\n    }\n\n    function getAmountsOut(uint amountIn, address[] calldata path) external override view returns (uint[] memory amounts){\n        return _uniswapV2Router.getAmountsOut(amountIn, path);\n    }\n\n    function getAmountsIn(uint amountOut, address[] calldata path) external override view returns (uint[] memory amounts){\n        return _uniswapV2Router.getAmountsIn(amountOut, path);\n    }\n    \n    /**\n    * @dev Wraps all tokens in the contract and sends them to the charity \n    * address \n    * To know why, see takeFeeETH() \n    */\n    function withdraw() external {\n        uint256 contractBalance = address(this).balance;\n        IWETH(_WETH).deposit{value: contractBalance}();\n        IWETH(_WETH).transfer(_charityAddress, contractBalance);\n    }\n\n    /**\n    * @dev Functions that only the owner can call that change the variables\n    * in this contract\n    */\n    function setCharityFee(uint256 newCharityFee) external onlyOwner {\n        _charityFee = newCharityFee;\n    }\n    \n    function setCharityAddress(address newCharityAddress) external onlyOwner {\n        _charityAddress = newCharityAddress;\n    }\n    \n    function setUniswapV2Router(IUniswapV2Router newUniswapV2Router) external onlyOwner {\n        _uniswapV2Router = newUniswapV2Router;\n    }\n\n    function setWETH(address newWETH) external onlyOwner {\n        _WETH = newWETH;\n    }\n    \n    /**\n    * @return Returns the % fee taken from each swap that goes to charity\n    */\n    function charityFee() external view returns (uint256) {\n        return _charityFee;\n    }\n    \n    /**\n    * @return The address that the \"Charity Fee\" is sent to\n    */\n    function charityAddress() external view returns (address) {\n        return _charityAddress;\n    }\n    \n    /**\n    * @return The router that all swaps will be directed through\n    */\n    function uniswapV2Router() external view returns (IUniswapV2Router) {\n        return _uniswapV2Router;\n    }\n\n    /**\n    * @return The current WETH contract that\u0027s being used\n    */\n    function WETH() external view returns (address) {\n        return _WETH;\n    }\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}"}}