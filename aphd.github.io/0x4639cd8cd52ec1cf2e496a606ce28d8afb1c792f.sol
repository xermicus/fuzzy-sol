{"BREE.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\r\npragma solidity ^0.6.0;\r\n\r\n// ----------------------------------------------------------------------------\r\n// \u0027BREE\u0027 token contract\r\n\r\n// Symbol      : BREE \r\n// Name        : CBDAO \r\n// Total supply: 10 million\r\n// Decimals    : 18\r\n// ----------------------------------------------------------------------------\r\n\r\nimport \u0027./SafeMath.sol\u0027;\r\nimport \u0027./ERC20contract.sol\u0027;\r\nimport \u0027./Owned.sol\u0027;\r\n\r\n// ----------------------------------------------------------------------------\r\n// ERC20 Token, with the addition of symbol, name and decimals and assisted\r\n// token transfers\r\n// ----------------------------------------------------------------------------\r\ncontract Token is ERC20Interface, Owned {\r\n    using SafeMath for uint256;\r\n    string public symbol = \"BREE\";\r\n    string public  name = \"CBDAO\";\r\n    uint256 public decimals = 18;\r\n    uint256 private maxCapSupply = 1e7 * 10**(decimals); // 10 million\r\n    uint256 _totalSupply = 1530409 * 10 ** (decimals); // 1,530,409\r\n    address stakeFarmingContract;\r\n    \r\n    mapping(address =\u003e uint256) balances;\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) allowed;\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Constructor\r\n    // ------------------------------------------------------------------------\r\n    constructor() public {\r\n        // mint _totalSupply amount of tokens and send to owner\r\n        balances[owner] = balances[owner].add(_totalSupply);\r\n        emit Transfer(address(0),owner, _totalSupply);\r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Set the STAKE_FARMING_CONTRACT\r\n    // @required only owner\r\n    // ------------------------------------------------------------------------\r\n    function SetStakeFarmingContract(address _address) external onlyOwner{\r\n        require(_address != address(0), \"Invalid address\");\r\n        stakeFarmingContract = _address;\r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Token Minting function\r\n    // @params _amount expects the amount of tokens to be minted excluding the \r\n    // required decimals\r\n    // @params _beneficiary tokens will be sent to _beneficiary\r\n    // @required only owner OR stakeFarmingContract\r\n    // ------------------------------------------------------------------------\r\n    function MintTokens(uint256 _amount, address _beneficiary) public returns(bool){\r\n        require(msg.sender == stakeFarmingContract);\r\n        require(_beneficiary != address(0), \"Invalid address\");\r\n        require(_totalSupply.add(_amount) \u003c= maxCapSupply, \"exceeds max cap supply 10 million\");\r\n        _totalSupply = _totalSupply.add(_amount);\r\n        \r\n        // mint _amount tokens and keep inside contract\r\n        balances[_beneficiary] = balances[_beneficiary].add(_amount);\r\n        \r\n        emit Transfer(address(0),_beneficiary, _amount);\r\n        return true;\r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Burn the `_amount` amount of tokens from the calling `account`\r\n    // @params _amount the amount of tokens to burn\r\n    // ------------------------------------------------------------------------\r\n    function BurnTokens(uint256 _amount) external {\r\n        _burn(_amount, msg.sender);\r\n    }\r\n\r\n    // ------------------------------------------------------------------------\r\n    // @dev Internal function that burns an amount of the token from a given account\r\n    // @param _amount The amount that will be burnt\r\n    // @param _account The tokens to burn from\r\n    // ------------------------------------------------------------------------\r\n    function _burn(uint256 _amount, address _account) internal {\r\n        require(balances[_account] \u003e= _amount, \"insufficient account balance\");\r\n        _totalSupply = _totalSupply.sub(_amount);\r\n        balances[_account] = balances[_account].sub(_amount);\r\n        emit Transfer(_account, address(0), _amount);\r\n    }\r\n    \r\n    /** ERC20Interface function\u0027s implementation **/\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Get the total supply of the `token`\r\n    // ------------------------------------------------------------------------\r\n    function totalSupply() public override view returns (uint256){\r\n       return _totalSupply; \r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Get the token balance for account `tokenOwner`\r\n    // ------------------------------------------------------------------------\r\n    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {\r\n        return balances[tokenOwner];\r\n    }\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Transfer the balance from token owner\u0027s account to `to` account\r\n    // - Owner\u0027s account must have sufficient balance to transfer\r\n    // - 0 value transfers are allowed\r\n    // ------------------------------------------------------------------------\r\n    function transfer(address to, uint256 tokens) public override returns  (bool success) {\r\n        // prevent transfer to 0x0, use burn instead\r\n        require(address(to) != address(0));\r\n        require(balances[msg.sender] \u003e= tokens );\r\n        require(balances[to].add(tokens) \u003e= balances[to]);\r\n            \r\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n        balances[to] = balances[to].add(tokens);\r\n        emit Transfer(msg.sender,to,tokens);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See `IERC20.approve`.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 value) public override returns (bool) {\r\n        _approve(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    // ------------------------------------------------------------------------\r\n    // Transfer `tokens` from the `from` account to the `to` account\r\n    // \r\n    // The calling account must already have sufficient tokens approve(...)-d\r\n    // for spending from the `from` account and\r\n    // - From account must have sufficient balance to transfer\r\n    // - Spender must have sufficient allowance to transfer\r\n    // - 0 value transfers are allowed\r\n    // ------------------------------------------------------------------------\r\n    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){\r\n        require(tokens \u003c= allowed[from][msg.sender]); //check allowance\r\n        require(balances[from] \u003e= tokens);\r\n        require(from != address(0), \"Invalid address\");\r\n        require(to != address(0), \"Invalid address\");\r\n        \r\n        balances[from] = balances[from].sub(tokens);\r\n        balances[to] = balances[to].add(tokens);\r\n        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n        emit Transfer(from,to,tokens);\r\n        return true;\r\n    }\r\n    \r\n    // ------------------------------------------------------------------------\r\n    // Returns the amount of tokens approved by the owner that can be\r\n    // transferred to the spender\u0027s account\r\n    // ------------------------------------------------------------------------\r\n    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {\r\n        return allowed[tokenOwner][spender];\r\n    }\r\n    \r\n    /**\r\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to `approve` that can be used as a mitigation for\r\n     * problems described in `IERC20.approve`.\r\n     *\r\n     * Emits an `Approval` event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, allowed[msg.sender][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to `approve` that can be used as a mitigation for\r\n     * problems described in `IERC20.approve`.\r\n     *\r\n     * Emits an `Approval` event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     * - `spender` must have allowance for the caller of at least\r\n     * `subtractedValue`.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedValue));\r\n        return true;\r\n    }\r\n    \r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.\r\n     *\r\n     * This is internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an `Approval` event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `owner` cannot be the zero address.\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 value) internal {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        allowed[owner][spender] = value;\r\n        emit Approval(owner, spender, value);\r\n    }\r\n}"},"ERC20contract.sol":{"content":"// \"SPDX-License-Identifier: UNLICENSED \"\r\npragma solidity ^0.6.0;\r\n// ----------------------------------------------------------------------------\r\n// ERC Token Standard #20 Interface\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n// ----------------------------------------------------------------------------\r\nabstract contract ERC20Interface {\r\n    function totalSupply() public virtual view returns (uint);\r\n    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);\r\n    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);\r\n    function transfer(address to, uint256 tokens) public virtual returns (bool success);\r\n    function approve(address spender, uint256 tokens) public virtual returns (bool success);\r\n    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);\r\n}"},"Owned.sol":{"content":"// \"SPDX-License-Identifier: UNLICENSED \"\r\npragma solidity ^0.6.0;\r\n// ----------------------------------------------------------------------------\r\n// Owned contract\r\n// ----------------------------------------------------------------------------\r\ncontract Owned {\r\n    address payable public owner;\r\n\r\n    event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address payable _newOwner) public onlyOwner {\r\n        owner = _newOwner;\r\n        emit OwnershipTransferred(msg.sender, _newOwner);\r\n    }\r\n}"},"SafeMath.sol":{"content":"// \"SPDX-License-Identifier: UNLICENSED \"\r\npragma solidity ^0.6.0;\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n *\r\n*/\r\n \r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003c= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a + b;\r\n    assert(c \u003e= a);\r\n    return c;\r\n  }\r\n  \r\n  function ceil(uint a, uint m) internal pure returns (uint r) {\r\n    return (a + m - 1) / m * m;\r\n  }\r\n}"}}