{"Context.sol":{"content":"// SPDX-License-Identifier: Apache license 2.0\r\n\r\npragma solidity ^0.7.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n  function _msgSender() internal virtual view returns (address payable) {\r\n    return msg.sender;\r\n  }\r\n\r\n  function _msgData() internal virtual view returns (bytes memory) {\r\n    this;\r\n    return msg.data;\r\n  }\r\n}"},"EarlyToken.sol":{"content":"// SPDX-License-Identifier: Apache license 2.0\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"./ERC20Burnable.sol\";\r\nimport \"./SafeMathUint.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\n/**\r\n * @dev EggToken is a {ERC20} implementation with various extensions\r\n * and custom functionality.\r\n */\r\ncontract EarlyToken is ERC20Burnable, Ownable {\r\n  using SafeMathUint for uint256;\r\n\r\n  /**\r\n   * @dev Sets the values for {name} and {symbol}, allocates the `initialTotalSupply`.\r\n   */\r\n  constructor() ERC20(\u0027EarlyToken\u0027, \u0027ERL\u0027) {\r\n    _totalSupply = 10000000000*(10**6);\r\n    _balances[_msgSender()] = _balances[_msgSender()].add(_totalSupply);\r\n    emit Transfer(address(0), _msgSender(), _totalSupply);\r\n  }\r\n}"},"ERC20.sol":{"content":"// SPDX-License-Identifier: Apache license 2.0\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"./Context.sol\";\r\nimport \"./IERC20.sol\";\r\nimport \"./SafeMathUint.sol\";\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using {_mint}.\r\n *\r\n * Functions revert instead of returning `false` on failure.\r\n * This behavior is nonetheless conventional\r\n * and does not conflict with the expectations of ERC20 applications.\r\n *\r\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * The non-standard {decreaseAllowance} and {increaseAllowance}\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See {IERC20-approve}.\r\n */\r\ncontract ERC20 is Context, IERC20 {\r\n  using SafeMathUint for uint256;\r\n\r\n  mapping(address =\u003e uint256) internal _balances;\r\n\r\n  mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n\r\n  uint256 internal _totalSupply;\r\n\r\n  string private _name;\r\n  string private _symbol;\r\n  uint8 private _decimals;\r\n\r\n  /**\r\n   * @dev Sets the values for {name} and {symbol}, initializes {decimals} with\r\n   * a default value of 6.\r\n   *\r\n   * To select a different value for {decimals}, use {_setupDecimals}.\r\n   *\r\n   * All three of these values are immutable: they can only be set once during\r\n   * construction.\r\n   */\r\n  constructor(string memory name, string memory symbol) {\r\n    _name = name;\r\n    _symbol = symbol;\r\n    _decimals = 6;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the name of the token.\r\n   */\r\n  function name() public view returns (string memory) {\r\n    return _name;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the symbol of the token, usually a shorter version of the\r\n   * name.\r\n   */\r\n  function symbol() public view returns (string memory) {\r\n    return _symbol;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the number of decimals used to get its user representation.\r\n   * For example, if `decimals` equals `2`, a balance of `505` tokens should\r\n   * be displayed to a user as `5,05` (`505 / 10 ** 2`).\r\n   *\r\n   * Tokens usually opt for a value of 6, imitating the relationship between\r\n   * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is\r\n   * called.\r\n   *\r\n   * NOTE: This information is only used for _display_ purposes: it in\r\n   * no way affects any of the arithmetic of the contract, including\r\n   * {IERC20-balanceOf} and {IERC20-transfer}.\r\n   */\r\n  function decimals() public view returns (uint8) {\r\n    return _decimals;\r\n  }\r\n\r\n  /**\r\n   * @dev See {IERC20-totalSupply}.\r\n   */\r\n  function totalSupply() public override view returns (uint256) {\r\n    return _totalSupply;\r\n  }\r\n\r\n  /**\r\n   * @dev See {IERC20-balanceOf}.\r\n   */\r\n  function balanceOf(address account) public override view returns (uint256) {\r\n    return _balances[account];\r\n  }\r\n\r\n  /**\r\n   * @dev See {IERC20-transfer}.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `recipient` cannot be the zero address.\r\n   * - the caller must have a balance of at least `amount`.\r\n   */\r\n  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n    _transfer(_msgSender(), recipient, amount);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev See {IERC20-allowance}.\r\n   */\r\n  function allowance(address owner, address spender)\r\n    public\r\n    virtual\r\n    override\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return _allowances[owner][spender];\r\n  }\r\n\r\n  /**\r\n   * @dev See {IERC20-approve}.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `spender` cannot be the zero address.\r\n   */\r\n  function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n    _approve(_msgSender(), spender, amount);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev See {IERC20-transferFrom}.\r\n   *\r\n   * Emits an {Approval} event indicating the updated allowance. This is not\r\n   * required by the EIP. See the note at the beginning of {ERC20}.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `sender` and `recipient` cannot be the zero address.\r\n   * - `sender` must have a balance of at least `amount`.\r\n   * - the caller must have allowance for ``sender``\u0027s tokens of at least\r\n   * `amount`.\r\n   */\r\n  function transferFrom(\r\n    address sender,\r\n    address recipient,\r\n    uint256 amount\r\n  ) public virtual override returns (bool) {\r\n    _transfer(sender, recipient, amount);\r\n    _approve(\r\n      sender,\r\n      _msgSender(),\r\n      _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\")\r\n    );\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n   *\r\n   * This is an alternative to {approve} that can be used as a mitigation for\r\n   * problems described in {IERC20-approve}.\r\n   *\r\n   * Emits an {Approval} event indicating the updated allowance.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `spender` cannot be the zero address.\r\n   */\r\n  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n   *\r\n   * This is an alternative to {approve} that can be used as a mitigation for\r\n   * problems described in {IERC20-approve}.\r\n   *\r\n   * Emits an {Approval} event indicating the updated allowance.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `spender` cannot be the zero address.\r\n   * - `spender` must have allowance for the caller of at least\r\n   * `subtractedValue`.\r\n   */\r\n  function decreaseAllowance(address spender, uint256 subtractedValue)\r\n    public\r\n    virtual\r\n    returns (bool)\r\n  {\r\n    _approve(\r\n      _msgSender(),\r\n      spender,\r\n      _allowances[_msgSender()][spender].sub(\r\n        subtractedValue,\r\n        \"ERC20: decreased allowance below zero\"\r\n      )\r\n    );\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Moves tokens `amount` from `sender` to `recipient`.\r\n   *\r\n   * This is internal function is equivalent to {transfer}, and can be used to\r\n   * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n   *\r\n   * Emits a {Transfer} event.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `sender` cannot be the zero address.\r\n   * - `recipient` cannot be the zero address.\r\n   * - `sender` must have a balance of at least `amount`.\r\n   */\r\n  function _transfer(\r\n    address sender,\r\n    address recipient,\r\n    uint256 amount\r\n  ) internal virtual {\r\n    require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n    require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n    _beforeTokenTransfer(sender, recipient, amount);\r\n\r\n    _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\r\n    _balances[recipient] = _balances[recipient].add(amount);\r\n    emit Transfer(sender, recipient, amount);\r\n  }\r\n\r\n  /** @dev Creates `amount` tokens and assigns them to `account`, increasing\r\n   * the total supply.\r\n   *\r\n   * Emits a {Transfer} event with `from` set to the zero address.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `to` cannot be the zero address.\r\n   */\r\n  function _mint(address account, uint256 amount) internal virtual {\r\n    require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n    _beforeMint();\r\n    _beforeTokenTransfer(address(0), account, amount);\r\n\r\n    _totalSupply = _totalSupply.add(amount);\r\n    _balances[account] = _balances[account].add(amount);\r\n    emit Transfer(address(0), account, amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Destroys `amount` tokens from `account`, reducing the\r\n   * total supply.\r\n   *\r\n   * Emits a {Transfer} event with `to` set to the zero address.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `account` cannot be the zero address.\r\n   * - `account` must have at least `amount` tokens.\r\n   */\r\n  function _burn(address account, uint256 amount) internal virtual {\r\n    require(account != address(0), \"ERC20: burn from the zero address\");\r\n\r\n    _beforeTokenTransfer(account, address(0), amount);\r\n\r\n    _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\r\n    _totalSupply = _totalSupply.sub(amount);\r\n    emit Transfer(account, address(0), amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\r\n   *\r\n   * This internal function is equivalent to `approve`, and can be used to\r\n   * e.g. set automatic allowances for certain subsystems, etc.\r\n   *\r\n   * Emits an {Approval} event.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `owner` cannot be the zero address.\r\n   * - `spender` cannot be the zero address.\r\n   */\r\n  function _approve(\r\n    address owner,\r\n    address spender,\r\n    uint256 amount\r\n  ) internal virtual {\r\n    require(owner != address(0), \"ERC20: approve from the zero address\");\r\n    require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n    _allowances[owner][spender] = amount;\r\n    emit Approval(owner, spender, amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Hook that is called before any transfer of tokens. This includes\r\n   * minting and burning.\r\n   */\r\n  function _beforeTokenTransfer(\r\n    address from,\r\n    address to,\r\n    uint256 amount\r\n  ) internal virtual {}\r\n\r\n  /**\r\n   * @dev Hook that is called before any token mint.\r\n   */\r\n  function _beforeMint() internal virtual {}\r\n}"},"ERC20Burnable.sol":{"content":"// SPDX-License-Identifier: Apache license 2.0\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"./Context.sol\";\r\nimport \"./ERC20.sol\";\r\nimport \"./SafeMathUint.sol\";\r\n\r\n/**\r\n * @dev Extension of {ERC20} that allows token holders to destroy both their own\r\n * tokens and those that they have an allowance for, in a way that can be\r\n * recognized off-chain (via event analysis).\r\n */\r\nabstract contract ERC20Burnable is Context, ERC20 {\r\n  using SafeMathUint for uint256;\r\n\r\n  /**\r\n   * @dev Destroys `amount` tokens from the caller.\r\n   *\r\n   * See {ERC20-_burn}.\r\n   */\r\n  function burn(uint256 amount) external virtual returns (bool success) {\r\n    _burn(_msgSender(), amount);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Destroys `amount` tokens from `account`, deducting from the caller\u0027s\r\n   * allowance.\r\n   *\r\n   * See {ERC20-_burn} and {ERC20-allowance}.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - the caller must have allowance for `accounts`\u0027s tokens of at least\r\n   * `amount`.\r\n   */\r\n  function burnFrom(address account, uint256 amount) external virtual returns (bool success) {\r\n    uint256 decreasedAllowance = allowance(account, _msgSender()).sub(\r\n      amount,\r\n      \"ERC20Burnable: burn amount exceeds allowance\"\r\n    );\r\n    _approve(account, _msgSender(), decreasedAllowance);\r\n    _burn(account, amount);\r\n    return true;\r\n  }\r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: Apache license 2.0\r\n\r\npragma solidity ^0.7.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n  /**\r\n   * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n   * another (`to`).\r\n   *\r\n   * Note that `value` may be zero.\r\n   */\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n  /**\r\n   * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n   * a call to {approve}. `value` is the new allowance.\r\n   */\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n  /**\r\n   * @dev Returns the amount of tokens in existence.\r\n   */\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  /**\r\n   * @dev Returns the amount of tokens owned by `account`.\r\n   */\r\n  function balanceOf(address account) external view returns (uint256);\r\n\r\n  /**\r\n   * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n   *\r\n   * Returns a boolean value indicating whether the operation succeeded.\r\n   *\r\n   * Emits a {Transfer} event.\r\n   */\r\n  function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n  /**\r\n   * @dev Returns the remaining number of tokens that `spender` will be\r\n   * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n   * zero by default.\r\n   *\r\n   * This value changes when {approve} or {transferFrom} are called.\r\n   */\r\n  function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n  /**\r\n   * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n   *\r\n   * Returns a boolean value indicating whether the operation succeeded.\r\n   *\r\n   * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n   * that someone may use both the old and the new allowance by unfortunate\r\n   * transaction ordering. One possible solution to mitigate this race\r\n   * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n   * desired value afterwards:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   *\r\n   * Emits an {Approval} event.\r\n   */\r\n  function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n  /**\r\n   * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n   * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n   * allowance.\r\n   *\r\n   * Returns a boolean value indicating whether the operation succeeded.\r\n   *\r\n   * Emits a {Transfer} event.\r\n   */\r\n  function transferFrom(\r\n    address sender,\r\n    address recipient,\r\n    uint256 amount\r\n  ) external returns (bool);\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: Apache license 2.0\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable is Context {\r\n  event LogOwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n  address private _owner;\r\n\r\n  /**\r\n   * @dev Initializes the contract setting the deployer as the initial owner.\r\n   */\r\n  constructor() {\r\n    _owner = _msgSender();\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the address of the current owner.\r\n   */\r\n  function owner() public view returns (address) {\r\n    return _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(_msgSender() == _owner, \"Ownable: only contract owner can call this function.\");\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Checks if transaction sender account is an owner.\r\n   */\r\n  function isOwner() external view returns (bool) {\r\n    return _msgSender() == _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n   * Can only be called by the current owner.\r\n   */\r\n  function transferOwnership(address newOwner) external onlyOwner {\r\n    require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n    emit LogOwnershipTransferred(_owner, newOwner);\r\n    _owner = newOwner;\r\n  }\r\n}"},"SafeMathUint.sol":{"content":"// SPDX-License-Identifier: Apache license 2.0\r\n\r\npragma solidity ^0.7.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMathUint` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMathUint {\r\n  /**\r\n   * @dev Returns the addition of two unsigned integers, reverting on\r\n   * overflow.\r\n   *\r\n   * Counterpart to Solidity\u0027s `+` operator.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - Addition cannot overflow.\r\n   */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a + b;\r\n    require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the subtraction of two unsigned integers, reverting on\r\n   * overflow (when the result is negative).\r\n   *\r\n   * Counterpart to Solidity\u0027s `-` operator.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - Subtraction cannot overflow.\r\n   */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return sub(a, b, \"SafeMath: subtraction overflow\");\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n   * overflow (when the result is negative).\r\n   *\r\n   * Counterpart to Solidity\u0027s `-` operator.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - Subtraction cannot overflow.\r\n   */\r\n  function sub(\r\n    uint256 a,\r\n    uint256 b,\r\n    string memory errorMessage\r\n  ) internal pure returns (uint256) {\r\n    require(b \u003c= a, errorMessage);\r\n    uint256 c = a - b;\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the multiplication of two unsigned integers, reverting on\r\n   * overflow.\r\n   *\r\n   * Counterpart to Solidity\u0027s `*` operator.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - Multiplication cannot overflow.\r\n   */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    uint256 c = a * b;\r\n    require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the integer division of two unsigned integers. Reverts on\r\n   * division by zero. The result is rounded towards zero.\r\n   *\r\n   * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n   * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n   * uses an invalid opcode to revert (consuming all remaining gas).\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - The divisor cannot be zero.\r\n   */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return div(a, b, \"SafeMath: division by zero\");\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n   * division by zero. The result is rounded towards zero.\r\n   *\r\n   * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n   * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n   * uses an invalid opcode to revert (consuming all remaining gas).\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - The divisor cannot be zero.\r\n   */\r\n  function div(\r\n    uint256 a,\r\n    uint256 b,\r\n    string memory errorMessage\r\n  ) internal pure returns (uint256) {\r\n    require(b \u003e 0, errorMessage);\r\n    uint256 c = a / b;\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n   * Reverts when dividing by zero.\r\n   *\r\n   * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n   * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n   * invalid opcode to revert (consuming all remaining gas).\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - The divisor cannot be zero.\r\n   */\r\n  function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return mod(a, b, \"SafeMath: modulo by zero\");\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n   * Reverts with custom message when dividing by zero.\r\n   *\r\n   * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n   * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n   * invalid opcode to revert (consuming all remaining gas).\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - The divisor cannot be zero.\r\n   */\r\n  function mod(\r\n    uint256 a,\r\n    uint256 b,\r\n    string memory errorMessage\r\n  ) internal pure returns (uint256) {\r\n    require(b != 0, errorMessage);\r\n    return a % b;\r\n  }\r\n\r\n  /**\r\n   * @dev Converts an unsigned integer to a signed integer,\r\n   * Reverts when convertation overflows.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - Operation cannot overflow.\r\n   */\r\n  function toInt256Safe(uint256 a) internal pure returns (int256) {\r\n    int256 b = int256(a);\r\n    require(b \u003e= 0, \"SafeMath: convertation overflow\");\r\n    return b;\r\n  }\r\n}"}}