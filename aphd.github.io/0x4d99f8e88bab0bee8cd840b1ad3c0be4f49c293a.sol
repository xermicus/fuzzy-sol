{"Address.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// Copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol\r\n// and modified it.\r\n\r\npragma solidity \u003e=0.8;\r\n\r\nlibrary Address {\r\n    /**\r\n     * @dev Returns true if `account` is a contract.\r\n     *\r\n     * [IMPORTANT]\r\n     * ====\r\n     * It is unsafe to assume that an address for which this function returns\r\n     * false is an externally-owned account (EOA) and not a contract.\r\n     *\r\n     * Among others, `isContract` will return false for the following\r\n     * types of addresses:\r\n     *\r\n     *  - an externally-owned account\r\n     *  - a contract in construction\r\n     *  - an address where a contract will be created\r\n     *  - an address where a contract lived, but was destroyed\r\n     * ====\r\n     */\r\n    function isContract(address account) internal view returns (bool) {\r\n        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\r\n        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\r\n        // for accounts without code, i.e. `keccak256(\u0027\u0027)`\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != accountHash \u0026\u0026 codehash != 0x0);\r\n    }\r\n\r\n    function functionCallWithValue(address target, bytes memory data, uint256 weiValue) internal returns (bytes memory) {\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        require(data.length == 0 || isContract(target));\r\n        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);\r\n        if (success) {\r\n            return returndata;\r\n        } else {\r\n            // TODO: I think this does not lead to correct error messages.\r\n            revert(string(returndata));\r\n        }\r\n    }\r\n}"},"IERC20.sol":{"content":"/**\r\n* SPDX-License-Identifier: MIT\r\n*\r\n* Copyright (c) 2016-2019 zOS Global Limited\r\n*\r\n*/\r\npragma solidity \u003e=0.8;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see `ERC20Detailed`.\r\n */\r\n\r\ninterface IERC20 {\r\n\r\n    // Optional functions\r\n    function name() external view returns (string memory);\r\n\r\n    function symbol() external view returns (string memory);\r\n\r\n    function decimals() external view returns (uint8);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a `Transfer` event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through `transferFrom`. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when `approve` or `transferFrom` are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003e Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an `Approval` event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a `Transfer` event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to `approve`. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"ITokenReceiver.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// Copied from https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/UniswapV2Router02.sol\r\npragma solidity \u003e=0.8;\r\n\r\ninterface ITokenReceiver {\r\n\r\n    function onTokenTransfer(address token, address from, uint256 amount, bytes calldata data) external;\r\n\r\n}"},"IUniswapV2.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// Copied from https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/UniswapV2Router02.sol\r\npragma solidity \u003e=0.8;\r\n\r\ninterface IUniswapV2 {\r\n\r\n        function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)\r\n                external payable returns (uint[] memory amounts);\r\n\r\n        function getAmountsIn(uint amountOut, address[] memory path)\r\n                external view returns (uint[] memory amounts);\r\n\r\n        function getAmountsOut(uint amountIn, address[] memory path)\r\n                external view returns (uint[] memory amounts);\r\n        \r\n        function WETH() external pure returns (address);\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n//\r\n// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol\r\n//\r\n// Modifications:\r\n// - Replaced Context._msgSender() with msg.sender\r\n// - Made leaner\r\n\r\npragma solidity \u003e=0.8;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable {\r\n\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner == msg.sender, \"not owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}"},"PaymentHub.sol":{"content":"/**\r\n* SPDX-License-Identifier: LicenseRef-Aktionariat\r\n*\r\n* MIT License with Automated License Fee Payments\r\n*\r\n* Copyright (c) 2020 Aktionariat AG (aktionariat.com)\r\n*\r\n* Permission is hereby granted to any person obtaining a copy of this software\r\n* and associated documentation files (the \"Software\"), to deal in the Software\r\n* without restriction, including without limitation the rights to use, copy,\r\n* modify, merge, publish, distribute, sublicense, and/or sell copies of the\r\n* Software, and to permit persons to whom the Software is furnished to do so,\r\n* subject to the following conditions:\r\n*\r\n* - The above copyright notice and this permission notice shall be included in\r\n*   all copies or substantial portions of the Software.\r\n* - All automated license fee payments integrated into this and related Software\r\n*   are preserved.\r\n*\r\n* THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\r\n* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\r\n* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\r\n* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\r\n* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\r\n* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\r\n* SOFTWARE.\r\n*/\r\npragma solidity \u003e=0.8;\r\n\r\nimport \"./Address.sol\";\r\nimport \"./IERC20.sol\";\r\nimport \"./IUniswapV2.sol\";\r\nimport \"./ITokenReceiver.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\n/**\r\n * A hub for payments. This allows tokens that do not support ERC 677 to enjoy similar functionality,\r\n * namely interacting with a token-handling smart contract in one transaction, without having to set an allowance first.\r\n * Instead, an allowance needs to be set only once, namely for this contract.\r\n * Further, it supports automatic conversion from Ether to the payment currency through Uniswap.\r\n */\r\ncontract PaymentHub {\r\n\r\n    // immutable variables get integrated into the bytecode at deployment time, constants at compile time\r\n    // Unlike normal variables, changing their values changes the codehash of a contract!\r\n    IUniswapV2 constant uniswap = IUniswapV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);\r\n    IERC20 public immutable weth; \r\n    address public immutable currency;\r\n\r\n    constructor(address currency_) {\r\n        currency = currency_;\r\n        weth = IERC20(uniswap.WETH());\r\n    }\r\n\r\n    function getPath() private view returns (address[] memory) {\r\n        address[] memory path = new address[](2);\r\n        path[0] = address(weth);\r\n        path[1] = address(currency);\r\n        return path;\r\n    }\r\n\r\n    function getPriceInEther(uint256 amountOfXCHF) public view returns (uint256) {\r\n        return uniswap.getAmountsIn(amountOfXCHF, getPath())[0];\r\n    }\r\n\r\n    /**\r\n     * Convenience method to swap ether into currency and pay a target address\r\n     */\r\n    function payFromEther(address recipient, uint256 xchfamount) payable public {\r\n        uniswap.swapETHForExactTokens{value: msg.value}(xchfamount, getPath(), recipient, block.timestamp);\r\n        if (address(this).balance \u003e 0){\r\n            payable(msg.sender).transfer(address(this).balance); // return change\r\n        }\r\n    }\r\n\r\n    function multiPay(address[] calldata recipients, uint256[] calldata amounts) public {\r\n        multiPay(currency, recipients, amounts);\r\n    }\r\n\r\n    function multiPay(address token, address[] calldata recipients, uint256[] calldata amounts) public {\r\n        for (uint i=0; i\u003crecipients.length; i++) {\r\n            IERC20(token).transferFrom(msg.sender, recipients[i], amounts[i]);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Can (at least in theory) save some gas as the sender balance only is touched in one transaction.\r\n     */\r\n    function multiPayAndNotify(address token, address[] calldata recipients, uint256[] calldata amounts, bytes calldata ref) public {\r\n        for (uint i=0; i\u003crecipients.length; i++) {\r\n            payAndNotify(token, recipients[i], amounts[i], ref);\r\n        }\r\n    }\r\n\r\n/*     function approveAndCall(address token, uint256 amount, address target, bytes calldata data, uint256 weiValue) public returns (bytes memory) {\r\n        require((IERC20(token)).transferFrom(msg.sender, address(this), amount));\r\n        require((IERC20(token)).approve(target, amount));\r\n        return Address.functionCallWithValue(target, data, weiValue);\r\n    } */\r\n\r\n    // Allows to make a payment from the sender to an address given an allowance to this contract\r\n    // Equivalent to xchf.transferAndCall(recipient, xchfamount)\r\n    function payAndNotify(address recipient, uint256 xchfamount, bytes calldata ref) public {\r\n        payAndNotify(currency, recipient, xchfamount, ref);\r\n    }\r\n\r\n    function payAndNotify(address token, address recipient, uint256 amount, bytes calldata ref) public {\r\n        IERC20(token).transferFrom(msg.sender, recipient, amount);\r\n        ITokenReceiver(recipient).onTokenTransfer(token, msg.sender, amount, ref);\r\n    }\r\n\r\n    function payFromEtherAndNotify(address recipient, uint256 xchfamount, bytes calldata ref) payable public {\r\n        payFromEther(recipient, xchfamount);\r\n        ITokenReceiver(recipient).onTokenTransfer(address(currency), msg.sender, xchfamount, ref);\r\n    }\r\n\r\n    /**\r\n     * In case tokens have been accidentally sent directly to this contract.\r\n     * Make sure to be fast as anyone can call this!\r\n     */\r\n    function recover(address ercAddress, address to, uint256 amount) public {\r\n        IERC20(ercAddress).transfer(to, amount);\r\n    }\r\n\r\n}"}}