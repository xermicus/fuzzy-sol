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
    "contracts/Curve/Curve_Registry_V2_1.sol": {
      "content": "// ███████╗░█████╗░██████╗░██████╗░███████╗██████╗░░░░███████╗██╗\n// ╚════██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗░░░██╔════╝██║\n// ░░███╔═╝███████║██████╔╝██████╔╝█████╗░░██████╔╝░░░█████╗░░██║\n// ██╔══╝░░██╔══██║██╔═══╝░██╔═══╝░██╔══╝░░██╔══██╗░░░██╔══╝░░██║\n// ███████╗██║░░██║██║░░░░░██║░░░░░███████╗██║░░██║██╗██║░░░░░██║\n// ╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝\n// Copyright (C) 2020 zapper\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU Affero General Public License as published by\n// the Free Software Foundation, either version 2 of the License, or\n// (at your option) any later version.\n//\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU Affero General Public License for more details.\n//\n\n///@author Zapper\n///@notice Registry for Curve Pools with Utility functions.\n\n// SPDX-License-Identifier: GPL-2.0\n\npragma solidity ^0.8.0;\n\nimport \"../oz/0.8.0/access/Ownable.sol\";\nimport \"../oz/0.8.0/token/ERC20/utils/SafeERC20.sol\";\n\ninterface ICurveAddressProvider {\n    function get_registry() external view returns (address);\n\n    function get_address(uint256 _id) external view returns (address);\n}\n\ninterface ICurveRegistry {\n    function get_pool_from_lp_token(address lpToken)\n        external\n        view\n        returns (address);\n\n    function get_lp_token(address swapAddress) external view returns (address);\n\n    function get_n_coins(address _pool)\n        external\n        view\n        returns (uint256[2] memory);\n\n    function get_coins(address _pool) external view returns (address[8] memory);\n\n    function get_underlying_coins(address _pool)\n        external\n        view\n        returns (address[8] memory);\n}\n\ninterface ICurveFactoryRegistry {\n    function get_n_coins(address _pool) external view returns (uint256);\n\n    function get_coins(address _pool) external view returns (address[2] memory);\n\n    function get_underlying_coins(address _pool)\n        external\n        view\n        returns (address[8] memory);\n}\n\ninterface ICurveV2Pool {\n    function price_oracle(uint256 k) external view returns (uint256);\n}\n\ncontract Curve_Registry_V2_1 is Ownable {\n    using SafeERC20 for IERC20;\n\n    ICurveAddressProvider private constant CurveAddressProvider =\n        ICurveAddressProvider(0x0000000022D53366457F9d5E68Ec105046FC4383);\n    ICurveRegistry public CurveRegistry;\n\n    ICurveFactoryRegistry public FactoryRegistry;\n\n    address private constant wbtcToken =\n        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;\n    address private constant sbtcCrvToken =\n        0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3;\n    address internal constant ETHAddress =\n        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n\n    mapping(address => bool) public shouldAddUnderlying;\n    mapping(address => address) private depositAddresses;\n\n    constructor() {\n        CurveRegistry = ICurveRegistry(CurveAddressProvider.get_registry());\n        FactoryRegistry = ICurveFactoryRegistry(\n            CurveAddressProvider.get_address(3)\n        );\n    }\n\n    /**\n    @notice Checks if the pool is an original (non-factory) pool\n    @param swapAddress Curve swap address for the pool\n    @return true if pool is a non-factory pool, false otherwise\n    */\n    function isCurvePool(address swapAddress) public view returns (bool) {\n        if (CurveRegistry.get_lp_token(swapAddress) != address(0)) {\n            return true;\n        }\n        return false;\n    }\n\n    /**\n    @notice Checks if the pool is a factory pool\n    @param swapAddress Curve swap address for the pool\n    @return true if pool is a factory pool, false otherwise\n    */\n    function isFactoryPool(address swapAddress) public view returns (bool) {\n        if (FactoryRegistry.get_coins(swapAddress)[0] != address(0)) {\n            return true;\n        }\n        return false;\n    }\n\n    /**\n    @notice Checks if the Curve pool is a metapool\n    @notice All factory pools are metapools but not all metapools\n    * are factory pools! (e.g. dusd)\n    @param swapAddress Curve swap address for the pool\n    @return true if the pool is a metapool, false otherwise\n    */\n    function isMetaPool(address swapAddress) public view returns (bool) {\n        if (isCurvePool(swapAddress)) {\n            uint256[2] memory poolTokenCounts =\n                CurveRegistry.get_n_coins(swapAddress);\n\n            if (poolTokenCounts[0] == poolTokenCounts[1]) return false;\n            else return true;\n        }\n        if (isFactoryPool(swapAddress)) return true;\n        return false;\n    }\n\n    /**\n    @notice Checks if the pool is a Curve V2 pool\n    @param swapAddress Curve swap address for the pool\n    @return true if pool is a V2 pool, false otherwise\n    */\n    function isV2Pool(address swapAddress) public view returns (bool) {\n        try ICurveV2Pool(swapAddress).price_oracle(0) {\n            return true;\n        } catch {\n            return false;\n        }\n    }\n\n    /**\n    @notice Gets the Curve pool deposit address\n    @notice The deposit address is used for pools with wrapped (c, y) tokens\n    @param swapAddress Curve swap address for the pool\n    @return depositAddress Curve pool deposit address or the swap address if not mapped\n    */\n    function getDepositAddress(address swapAddress)\n        external\n        view\n        returns (address depositAddress)\n    {\n        depositAddress = depositAddresses[swapAddress];\n        if (depositAddress == address(0)) return swapAddress;\n    }\n\n    /**\n    @notice Gets the Curve pool swap address\n    @notice The token and swap address is the same for metapool/factory pools\n    @param tokenAddress Curve swap address for the pool\n    @return swapAddress Curve pool swap address or address(0) if pool doesnt exist\n    */\n    function getSwapAddress(address tokenAddress)\n        external\n        view\n        returns (address swapAddress)\n    {\n        swapAddress = CurveRegistry.get_pool_from_lp_token(tokenAddress);\n        if (swapAddress != address(0)) {\n            return swapAddress;\n        }\n        if (isFactoryPool(tokenAddress)) {\n            return tokenAddress;\n        }\n        return address(0);\n    }\n\n    /**\n    @notice Gets the Curve pool token address\n    @notice The token and swap address is the same for metapool/factory pools\n    @param swapAddress Curve swap address for the pool\n    @return tokenAddress Curve pool token address or address(0) if pool doesnt exist\n    */\n    function getTokenAddress(address swapAddress)\n        external\n        view\n        returns (address tokenAddress)\n    {\n        tokenAddress = CurveRegistry.get_lp_token(swapAddress);\n        if (tokenAddress != address(0)) {\n            return tokenAddress;\n        }\n        if (isFactoryPool(swapAddress)) {\n            return swapAddress;\n        }\n        return address(0);\n    }\n\n    /**\n    @notice Gets the number of non-underlying tokens in a pool\n    @param swapAddress Curve swap address for the pool\n    @return number of underlying tokens in the pool\n    */\n    function getNumTokens(address swapAddress) public view returns (uint256) {\n        if (isCurvePool(swapAddress)) {\n            return CurveRegistry.get_n_coins(swapAddress)[0];\n        } else {\n            return FactoryRegistry.get_n_coins(swapAddress);\n        }\n    }\n\n    /**\n    @notice Gets an array of underlying pool token addresses\n    @param swapAddress Curve swap address for the pool\n    @return poolTokens returns 4 element array containing the \n    * addresses of the pool tokens (0 address if pool contains < 4 tokens)\n    */\n    function getPoolTokens(address swapAddress)\n        public\n        view\n        returns (address[4] memory poolTokens)\n    {\n        if (isMetaPool(swapAddress)) {\n            if (isFactoryPool(swapAddress)) {\n                address[2] memory poolUnderlyingCoins =\n                    FactoryRegistry.get_coins(swapAddress);\n                for (uint256 i = 0; i < 2; i++) {\n                    poolTokens[i] = poolUnderlyingCoins[i];\n                }\n            } else {\n                address[8] memory poolUnderlyingCoins =\n                    CurveRegistry.get_coins(swapAddress);\n                for (uint256 i = 0; i < 2; i++) {\n                    poolTokens[i] = poolUnderlyingCoins[i];\n                }\n            }\n\n            return poolTokens;\n        } else {\n            address[8] memory poolUnderlyingCoins;\n            if (isBtcPool(swapAddress)) {\n                poolUnderlyingCoins = CurveRegistry.get_coins(swapAddress);\n            } else {\n                poolUnderlyingCoins = CurveRegistry.get_underlying_coins(\n                    swapAddress\n                );\n            }\n            for (uint256 i = 0; i < 4; i++) {\n                poolTokens[i] = poolUnderlyingCoins[i];\n            }\n        }\n    }\n\n    /**\n    @notice Checks if the Curve pool contains WBTC\n    @param swapAddress Curve swap address for the pool\n    @return true if the pool contains WBTC, false otherwise\n    */\n    function isBtcPool(address swapAddress) public view returns (bool) {\n        address[8] memory poolTokens = CurveRegistry.get_coins(swapAddress);\n        for (uint256 i = 0; i < 4; i++) {\n            if (poolTokens[i] == wbtcToken || poolTokens[i] == sbtcCrvToken)\n                return true;\n        }\n        return false;\n    }\n\n    /**\n    @notice Checks if the Curve pool contains ETH\n    @param swapAddress Curve swap address for the pool\n    @return true if the pool contains ETH, false otherwise\n    */\n    function isEthPool(address swapAddress) external view returns (bool) {\n        address[8] memory poolTokens = CurveRegistry.get_coins(swapAddress);\n        for (uint256 i = 0; i < 4; i++) {\n            if (poolTokens[i] == ETHAddress) {\n                return true;\n            }\n        }\n        return false;\n    }\n\n    /**\n    @notice Check if the pool contains the toToken\n    @param swapAddress Curve swap address for the pool\n    @param toToken contract address of the token\n    @return true if the pool contains the token, false otherwise\n    @return index of the token in the pool, 0 if pool does not contain the token\n    */\n    function isUnderlyingToken(address swapAddress, address toToken)\n        external\n        view\n        returns (bool, uint256)\n    {\n        address[4] memory poolTokens = getPoolTokens(swapAddress);\n        for (uint256 i = 0; i < 4; i++) {\n            if (poolTokens[i] == address(0)) return (false, 0);\n            if (poolTokens[i] == toToken) return (true, i);\n        }\n        return (false, 0);\n    }\n\n    /**\n    @notice Updates to the latest Curve registry from the address provider\n    */\n    function update_curve_registry() external onlyOwner {\n        address new_address = CurveAddressProvider.get_registry();\n\n        require(address(CurveRegistry) != new_address, \"Already updated\");\n\n        CurveRegistry = ICurveRegistry(new_address);\n    }\n\n    /**\n    @notice Updates to the latest Curve factory registry from the address provider\n    */\n    function update_factory_registry() external onlyOwner {\n        address new_address = CurveAddressProvider.get_address(3);\n\n        require(address(FactoryRegistry) != new_address, \"Already updated\");\n\n        FactoryRegistry = ICurveFactoryRegistry(new_address);\n    }\n\n    /**\n    @notice Add new pools which use the _use_underlying bool\n    @param swapAddresses Curve swap addresses for the pool\n    @param addUnderlying True if underlying tokens are always added\n    */\n    function updateShouldAddUnderlying(\n        address[] calldata swapAddresses,\n        bool[] calldata addUnderlying\n    ) external onlyOwner {\n        require(\n            swapAddresses.length == addUnderlying.length,\n            \"Mismatched arrays\"\n        );\n        for (uint256 i = 0; i < swapAddresses.length; i++) {\n            shouldAddUnderlying[swapAddresses[i]] = addUnderlying[i];\n        }\n    }\n\n    /**\n    @notice Add new pools which use uamounts for add_liquidity\n    @param swapAddresses Curve swap addresses to map from\n    @param _depositAddresses Curve deposit addresses to map to\n    */\n    function updateDepositAddresses(\n        address[] calldata swapAddresses,\n        address[] calldata _depositAddresses\n    ) external onlyOwner {\n        require(\n            swapAddresses.length == _depositAddresses.length,\n            \"Mismatched arrays\"\n        );\n        for (uint256 i = 0; i < swapAddresses.length; i++) {\n            depositAddresses[swapAddresses[i]] = _depositAddresses[i];\n        }\n    }\n\n    /**\n    //@notice Withdraw stuck tokens\n    */\n    function withdrawTokens(address[] calldata tokens) external onlyOwner {\n        for (uint256 i = 0; i < tokens.length; i++) {\n            uint256 qty;\n\n            if (tokens[i] == ETHAddress) {\n                qty = address(this).balance;\n                Address.sendValue(payable(owner()), qty);\n            } else {\n                qty = IERC20(tokens[i]).balanceOf(address(this));\n                IERC20(tokens[i]).safeTransfer(owner(), qty);\n            }\n        }\n    }\n}\n"
    },
    "contracts/oz/0.8.0/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(\n            newOwner != address(0),\n            \"Ownable: new owner is the zero address\"\n        );\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"
    },
    "contracts/oz/0.8.0/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount)\n        external\n        returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender)\n        external\n        view\n        returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(\n        address indexed owner,\n        address indexed spender,\n        uint256 value\n    );\n}\n"
    },
    "contracts/oz/0.8.0/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    function safeTransfer(\n        IERC20 token,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(\n            token,\n            abi.encodeWithSelector(token.transfer.selector, to, value)\n        );\n    }\n\n    function safeTransferFrom(\n        IERC20 token,\n        address from,\n        address to,\n        uint256 value\n    ) internal {\n        _callOptionalReturn(\n            token,\n            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)\n        );\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        // solhint-disable-next-line max-line-length\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(\n            token,\n            abi.encodeWithSelector(token.approve.selector, spender, value)\n        );\n    }\n\n    function safeIncreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(\n            token,\n            abi.encodeWithSelector(\n                token.approve.selector,\n                spender,\n                newAllowance\n            )\n        );\n    }\n\n    function safeDecreaseAllowance(\n        IERC20 token,\n        address spender,\n        uint256 value\n    ) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(\n                oldAllowance >= value,\n                \"SafeERC20: decreased allowance below zero\"\n            );\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(\n                token,\n                abi.encodeWithSelector(\n                    token.approve.selector,\n                    spender,\n                    newAllowance\n                )\n            );\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata =\n            address(token).functionCall(\n                data,\n                \"SafeERC20: low-level call failed\"\n            );\n        if (returndata.length > 0) {\n            // Return data is optional\n            // solhint-disable-next-line max-line-length\n            require(\n                abi.decode(returndata, (bool)),\n                \"SafeERC20: ERC20 operation did not succeed\"\n            );\n        }\n    }\n}\n"
    },
    "contracts/oz/0.8.0/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(\n            address(this).balance >= amount,\n            \"Address: insufficient balance\"\n        );\n\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\n        (bool success, ) = recipient.call{ value: amount }(\"\");\n        require(\n            success,\n            \"Address: unable to send value, recipient may have reverted\"\n        );\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain`call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data)\n        internal\n        returns (bytes memory)\n    {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return\n            functionCallWithValue(\n                target,\n                data,\n                value,\n                \"Address: low-level call with value failed\"\n            );\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(\n            address(this).balance >= value,\n            \"Address: insufficient balance for call\"\n        );\n        require(isContract(target), \"Address: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) =\n            target.call{ value: value }(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data)\n        internal\n        view\n        returns (bytes memory)\n    {\n        return\n            functionStaticCall(\n                target,\n                data,\n                \"Address: low-level static call failed\"\n            );\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data)\n        internal\n        returns (bytes memory)\n    {\n        return\n            functionDelegateCall(\n                target,\n                data,\n                \"Address: low-level delegate call failed\"\n            );\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    function _verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) private pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                // solhint-disable-next-line no-inline-assembly\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
    },
    "contracts/oz/0.8.0/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"
    }
  }
}}