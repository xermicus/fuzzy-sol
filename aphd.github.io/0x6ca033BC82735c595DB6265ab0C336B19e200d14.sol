{{
  "language": "Solidity",
  "sources": {
    "./contracts/ATTRToken.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol\";\nimport \"@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol\";\n\n// The ATTRToken is the Attrace utility token.\n// More info: https://attrace.com\n//\n// We keep the contract upgradeable during development to make sure we can evolve and implement gas optimizations later on.\n//\n// Upgrade strategy towards DAO:\n// -  Pre-DAO: the token is managed and improved by the Attrace project.\n// -  When DAO is achieved: the token will become owned by the DAO contracts, or if the DAO decides to lock the token, then it can do so by transferring ownership to a contract which can't be upgraded.\ncontract ATTRToken is ERC20Upgradeable {\n  // Accounts which can transfer out in the pre-listing period\n  mapping(address => bool) private _preListingAddrWL;\n\n  // Timestamp when rules are disabled, once this time is reached, this is irreversible\n  uint64 private _wlDisabledAt;\n\n  // Who can modify _preListingAddrWL and _wlDisabledAt (team doing the listing).\n  address private _wlController;\n\n  // Account time lock & vesting rules\n  mapping(address => TransferRule) public transferRules;\n\n  // Emitted whenever a transfer rule is configured\n  event TransferRuleConfigured(address addr, TransferRule rule);  \n\n  function initialize(address preListWlController) public initializer {\n    __ERC20_init(\"Attrace\", \"ATTR\");\n    _mint(msg.sender, 10 ** 27); // 1000000000000000000000000000 aces, 1,000,000,000 ATTR\n    _wlController = address(preListWlController);\n    _wlDisabledAt = 1624399200; // June 23 2021\n  }\n\n  // Hook into openzeppelin's ERC20Upgradeable flow to support golive requirements\n  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {\n    super._beforeTokenTransfer(from, to, amount);\n\n    // When not yet released, verify that the sender is white-listed.\n    if(_wlDisabledAt > block.timestamp) {\n      require(_preListingAddrWL[from] == true, \"not yet tradeable\");\n    }\n\n    // If we reach this, the token is already released and we verify the transfer rules which enforce locking and vesting.\n    if(transferRules[from].tokens > 0) {\n      uint lockedTokens = calcBalanceLocked(from);\n      uint balanceUnlocked = super.balanceOf(from) - lockedTokens;\n      require(amount <= balanceUnlocked, \"transfer rule violation\");\n    }\n\n    // If we reach this, the transfer is successful.\n    // Check if we should lock/vest the recipient of the tokens.\n    if(transferRules[from].outboundVestingMonths > 0 || transferRules[from].outboundTimeLockMonths > 0) {\n      // We don't support multiple rules, so recipient should not have vesting rules yet.\n      require(transferRules[to].tokens == 0, \"unsupported\");\n      transferRules[to].timeLockMonths = transferRules[from].outboundTimeLockMonths;\n      transferRules[to].vestingMonths = transferRules[from].outboundVestingMonths;\n      transferRules[to].tokens = uint96(amount);\n      transferRules[to].activationTime = uint40(block.timestamp);\n    }\n  }\n\n  // To support listing some addresses can be allowed transfers pre-listing.\n  function setPreReleaseAddressStatus(address addr, bool status) public {\n    require(_wlController == msg.sender);\n    _preListingAddrWL[addr] = status;\n  }\n\n  // Once pre-release rules are disabled, rules remain disabled\n  // While not expected to be used, in case of need (to support optimal listing), the team can control the time the token becomes tradeable.\n  function setNoRulesTime(uint64 disableTime) public {\n    require(_wlController == msg.sender); // Only controller can \n    require(_wlDisabledAt > uint64(block.timestamp)); // Can not be set anymore when rules are already disabled\n    require(disableTime > uint64(block.timestamp)); // Has to be in the future\n    _wlDisabledAt = disableTime;\n  }\n\n  // ---- LOCKING & VESTING RULES\n\n  // The contract embeds transfer rules for project go-live and vesting.\n  // Vesting rule describes the vesting rule a set of tokens is under since a relative time.\n  // This is gas-optimized and doesn't require the user to do any form of release() calls. \n  // When the periods expire, tokens will become tradeable.\n  struct TransferRule {\n    // The number of 30-day periods timelock this rule enforces.\n    // This timelock starts from the rule activation time.\n    uint16 timeLockMonths; // 2\n\n    // The number of 30-day periods vesting this rule enforces.\n    // This period starts after the timelock period has expired.\n    // The number of tokens released in every cycle equals rule.tokens/vestingMonths.\n    uint16 vestingMonths; // 2\n\n    // The number of tokens managed by the rule\n    // Eg: when ecosystem adoption sends N ATTR to an exchange, then this will have 1000 tokens.\n    uint96 tokens; // 12\n\n    // Time when the rule went into effect\n    // When the rule is 0, then the _wlDisabledAt time is used (time of listing).\n    // Eg: when ecosystem adoption wallet does a transfer to an exchange, the rule will receive block.timestamp.\n    uint40 activationTime; // 5\n\n    // Rules to apply to outbound transfers.\n    // Eg: ecosystem adoption wallet can do transfers, but all received assets will be under locked rules.\n    // When the recipient already has a vesting rule, the transfer will fail.\n    // rule.activationTime and rule.tokens will be set by the transfer caller.\n    uint16 outboundTimeLockMonths; // 2\n    uint16 outboundVestingMonths; // 2\n  }\n\n  // Calculate how many tokens are still locked for a holder \n  function calcBalanceLocked(address from) private view returns (uint) {\n    // When no activation time is defined, the moment of listing is used.\n    uint activationTime = (transferRules[from].activationTime == 0 ? _wlDisabledAt : transferRules[from].activationTime);\n\n    // First check the time lock\n    uint secondsLocked;\n    if(transferRules[from].timeLockMonths > 0) {\n      secondsLocked = (transferRules[from].timeLockMonths * (30 days));\n      if(activationTime+secondsLocked >= block.timestamp) {\n        // All tokens are still locked\n        return transferRules[from].tokens;\n      }\n    }\n\n    // If no time lock, then calculate how much is unlocked according to the vesting rules.\n    if(transferRules[from].vestingMonths > 0) {\n      uint vestingStart = activationTime + secondsLocked;\n      uint unlockedSlices = 0;\n      for(uint i = 0; i < transferRules[from].vestingMonths; i++) {\n        if(block.timestamp >= (vestingStart + (i * 30 days))) {\n          unlockedSlices++;\n        }\n      }\n      // If all months are vested, return 0 to ensure all tokens are sent back\n      if(transferRules[from].vestingMonths == unlockedSlices) {\n        return 0;\n      }\n\n      // Send back the amount of locked tokens\n      return (transferRules[from].tokens - ((transferRules[from].tokens / transferRules[from].vestingMonths) * unlockedSlices));\n    }\n\n    // No tokens are locked\n    return 0;\n  }\n\n  // The contract enforces all vesting and locking rules as desribed on https://attrace.com/community/attr-token/#distribution\n  // We don't lock tokens into another contract, we keep them allocated to the respective account, but with a locking rule on top of it.\n  // When the last vesting rule expires, checking the vesting rules is ignored automatically and overall gas off the transfers lowers with an SLOAD cost.\n  function setTransferRule(address addr, TransferRule calldata rule) public {\n    require(_wlDisabledAt > uint64(block.timestamp)); // Can only be set before listing\n    require(_wlController == msg.sender); // Only the whitelist controller can set rules before listing\n\n    // Validate the rule\n    require(\n      // Either a rule has a token vesting/lock\n      (rule.tokens > 0 && (rule.vestingMonths > 0 || rule.timeLockMonths > 0))\n      // And/or it has an outbound rule\n      || (rule.outboundTimeLockMonths > 0 || rule.outboundVestingMonths > 0), \n      \"invalid rule\");\n\n    // Store the rule\n    // Rules are allowed to have an empty activationTime, then listing moment will be used as activation time.\n    transferRules[addr] = rule;\n\n    // Emit event that a rule was set\n    emit TransferRuleConfigured(addr, rule);\n  }\n\n  function getLockedTokens(address addr) public view returns (uint256) {\n    return calcBalanceLocked(addr);\n  }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n// solhint-disable-next-line compiler-version\npragma solidity ^0.8.0;\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n */\nabstract contract Initializable {\n\n    /**\n     * @dev Indicates that the contract has been initialized.\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice.\n     */\n    modifier initializer() {\n        require(_initializing || !_initialized, \"Initializable: contract is already initialized\");\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20Upgradeable.sol\";\nimport \"./extensions/IERC20MetadataUpgradeable.sol\";\nimport \"../../utils/ContextUpgradeable.sol\";\nimport \"../../proxy/utils/Initializable.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin guidelines: functions revert instead\n * of returning `false` on failure. This behavior is nonetheless conventional\n * and does not conflict with the expectations of ERC20 applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn't required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {\n    mapping (address => uint256) private _balances;\n\n    mapping (address => mapping (address => uint256)) private _allowances;\n\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}.\n     *\n     * The defaut value of {decimals} is 18. To select a different value for\n     * {decimals} you should overload it.\n     *\n     * All two of these values are immutable: they can only be set once during\n     * construction.\n     */\n    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {\n        __Context_init_unchained();\n        __ERC20_init_unchained(name_, symbol_);\n    }\n\n    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the value {ERC20} uses, unless this function is\n     * overridden;\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view virtual override returns (uint8) {\n        return 18;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `recipient` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * Requirements:\n     *\n     * - `sender` and `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``sender``'s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\n        require(currentAllowance >= amount, \"ERC20: transfer amount exceeds allowance\");\n        _approve(sender, _msgSender(), currentAllowance - amount);\n\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\n        require(currentAllowance >= subtractedValue, \"ERC20: decreased allowance below zero\");\n        _approve(_msgSender(), spender, currentAllowance - subtractedValue);\n\n        return true;\n    }\n\n    /**\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\n     *\n     * This is internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `sender` cannot be the zero address.\n     * - `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     */\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _beforeTokenTransfer(sender, recipient, amount);\n\n        uint256 senderBalance = _balances[sender];\n        require(senderBalance >= amount, \"ERC20: transfer amount exceeds balance\");\n        _balances[sender] = senderBalance - amount;\n        _balances[recipient] += amount;\n\n        emit Transfer(sender, recipient, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _beforeTokenTransfer(address(0), account, amount);\n\n        _totalSupply += amount;\n        _balances[account] += amount;\n        emit Transfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _beforeTokenTransfer(account, address(0), amount);\n\n        uint256 accountBalance = _balances[account];\n        require(accountBalance >= amount, \"ERC20: burn amount exceeds balance\");\n        _balances[account] = accountBalance - amount;\n        _totalSupply -= amount;\n\n        emit Transfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens\n     * will be to transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }\n    uint256[45] private __gap;\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20Upgradeable {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20Upgradeable.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20MetadataUpgradeable is IERC20Upgradeable {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\nimport \"../proxy/utils/Initializable.sol\";\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract ContextUpgradeable is Initializable {\n    function __Context_init() internal initializer {\n        __Context_init_unchained();\n    }\n\n    function __Context_init_unchained() internal initializer {\n    }\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n    uint256[50] private __gap;\n}\n"
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