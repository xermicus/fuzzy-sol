{{
  "language": "Solidity",
  "sources": {
    "./contracts/tokenCounter.sol": {
      "content": "// SPDX-License-Identifier: AGPLV3\npragma solidity 0.8.4;\n\nimport \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"./common/Constants.sol\";\n\n// Uniswap pool interface\ninterface IUniPool{\n    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);\n    function totalSupply() external view returns (uint256);\n}\n\n// Balancer vault interface\ninterface IVault {\n    function getPoolTokens(bytes32 poolId)\n        external\n        view\n        returns (\n            IERC20[] memory tokens,\n            uint256[] memory balances,\n            uint256 lastChangeBlock\n        );\n}\n\n// Balancer pool interface\ninterface IBasePool {\n    function getVault() external view returns (IVault);\n    function getPoolId() external view returns (bytes32);\n}\n\ninterface ICurve {\n    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);\n}\n\nstruct UserInfo {\n    uint256 amount;\n    int256 rewardDebt;\n}\n\ninterface IMC {\n    function userInfo(uint256 poolId, address user) external view returns (UserInfo memory);\n}\n\n/* @notice Contract for helping bots to quickly asses users token amounts while minimizing number\n *      of calls to a node. Works for any standard ERC20 token, balancer or uniswap (uni, sushi etc) style pools, and curve meta pools.\n */\ncontract tokenCounter is Constants, Ownable {\n    using SafeERC20 for IERC20;\n\n\n    IMC masterChef = IMC(address(0x001C249c09090D79Dc350A286247479F08c7aaD7));\n    mapping(address => bool) msPool;\n    mapping(address => uint256) msPoolId;\n    event LogMCToken(address token, uint256 poolId, bool add);\n    \n    function addMCToken(address token, uint256 poolId, bool add) external onlyOwner {\n        msPool[token] = add;\n        msPoolId[token] = poolId;\n        emit LogMCToken(token, poolId, add);\n    }\n\n    /*\n     * @notice get balances of batch of users\n     * @param token address of token\n     * @param users users to get balances for\n     */\n    function getTokenAmounts(address token, address[] memory users) public view returns (uint256[] memory) {\n        uint256[] memory amounts = new uint256[](users.length);\n        bool ms = msPool[token];\n        for (uint256 i; i < users.length; i++) {\n            amounts[i] = IERC20(token).balanceOf(users[i]);\n            if (ms) amounts[i] += masterChef.userInfo(msPoolId[token], users[i]).amount;\n        }\n        return amounts;\n    }\n\n    /*\n     * @notice calculate composition of lp token\n     *      value of lp is defined by (in uniswap routerv2):\n     *          lp = Math.min(input0 * poolBalance / reserve0, input1 * poolBalance / reserve1)\n     *      which in turn implies:\n     *          input0 = reserve0 * lp / poolBalance\n     *          input1 = reserve1 * lp / poolBalance\n     * @param pool address of uniswap pool\n     * @param users users to get lp values for\n     */\n    function getLpAmountsUni(address pool, address[] memory users) external view returns (uint256[] memory, uint256[2][] memory) {\n        uint256[] memory userLpAmounts = new uint256[](users.length);\n        userLpAmounts = getTokenAmounts(pool, users);\n\n        (uint112 resA, uint112 resB, ) = IUniPool(pool).getReserves();\n        uint256 poolBalance = IUniPool(pool).totalSupply();\n        uint256[2][] memory lpPositions = new uint256[2][](users.length);\n\n        for (uint256 i; i < users.length; i++) {\n            lpPositions[i][0] = (userLpAmounts[i] * uint256(resA) * DEFAULT_DECIMALS_FACTOR / poolBalance) / DEFAULT_DECIMALS_FACTOR;\n            lpPositions[i][1] = (userLpAmounts[i] * uint256(resB) * DEFAULT_DECIMALS_FACTOR / poolBalance) / DEFAULT_DECIMALS_FACTOR;\n        }\n\n        return (userLpAmounts, lpPositions);\n    }\n\n    /*\n     * @notice calculate composition of lp token in balancer pool\n     *      value of lp is defined by balancer can be found @https://github.com/balancer-labs/balancer-v2-monorepo/blob/master/pkg/pool-weighted/contracts/WeightedMath.sol\n     *\n     *   exactBPTInForTokensOut                                                                    \n     *   (per token)                                                                              \n     *   aO = amountOut                  /        bptIn         \\                                \n     *   b = balance           a0 = b * | ---------------------  |                              \n     *   bptIn = bptAmountIn             \\       totalBPT       /                              \n     *   bpt = totalBPT                                                                       \n     *\n     * @param pool address of balancer pool\n     * @param users users to get lp values for\n     */\n    function getLpAmountsBalancer(address pool, address[] memory users) external view returns (uint256[] memory, uint256[2][] memory) {\n        uint256[] memory userLpAmounts = new uint256[](users.length);\n        userLpAmounts = getTokenAmounts(pool, users);\n\n        IVault vault = IBasePool(pool).getVault();\n        bytes32 poolId = IBasePool(pool).getPoolId();\n        (,uint256[] memory balances,) = vault.getPoolTokens(poolId);\n        \n        uint256 poolBalance = IERC20(pool).totalSupply();\n        uint256[2][] memory lpPositions = new uint256[2][](users.length);\n\n        for (uint256 i; i < users.length; i++) {\n            lpPositions[i][0] = (userLpAmounts[i] * uint256(balances[0]) * DEFAULT_DECIMALS_FACTOR / poolBalance) / DEFAULT_DECIMALS_FACTOR;\n            lpPositions[i][1] = (userLpAmounts[i] * uint256(balances[1]) * DEFAULT_DECIMALS_FACTOR / poolBalance) / DEFAULT_DECIMALS_FACTOR;\n        }\n\n        return (userLpAmounts, lpPositions);\n    }\n\n    /*\n     * @notice calculate PWRD value of users curve meta pool position\n     */\n    function getCurvePwrd(address pool, address[] memory users) external view returns (uint256[] memory, uint256[] memory) {\n        uint256[] memory userLpAmounts = new uint256[](users.length);\n        userLpAmounts = getTokenAmounts(pool, users);\n\n        uint256[] memory lpPositions = new uint256[](users.length);\n\n        for (uint256 i; i < users.length; i++) {\n            uint256 amount = userLpAmounts[i];\n            if (amount > 0)\n                lpPositions[i] = ICurve(pool).calc_withdraw_one_coin(amount, 0);\n        }\n\n        return (userLpAmounts, lpPositions);\n    }\n}\n\n"
    },
    "./contracts/common/Constants.sol": {
      "content": "// SPDX-License-Identifier: AGPLv3\npragma solidity ^0.8.0;\n\ncontract Constants {\n    uint8 internal constant N_COINS = 3;\n    uint8 internal constant DEFAULT_DECIMALS = 18; // GToken and Controller use this decimals\n    uint256 internal constant DEFAULT_DECIMALS_FACTOR = uint256(10)**DEFAULT_DECIMALS;\n    uint8 internal constant CHAINLINK_PRICE_DECIMALS = 8;\n    uint256 internal constant CHAINLINK_PRICE_DECIMAL_FACTOR = uint256(10)**CHAINLINK_PRICE_DECIMALS;\n    uint8 internal constant PERCENTAGE_DECIMALS = 4;\n    uint256 internal constant PERCENTAGE_DECIMAL_FACTOR = uint256(10)**PERCENTAGE_DECIMALS;\n    uint256 internal constant CURVE_RATIO_DECIMALS = 6;\n    uint256 internal constant CURVE_RATIO_DECIMALS_FACTOR = uint256(10)**CURVE_RATIO_DECIMALS;\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length > 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}