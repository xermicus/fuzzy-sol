{"CoinvestingDeFiToken.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\npragma solidity \u003e=0.8.0 \u003c0.9.0;\n\nimport \"./ERC20.sol\";\nimport \"./Ownable.sol\";\n\ncontract CoinvestingDeFiToken is Ownable, ERC20 {\n    // Public variables\n    address public saleReserve;\n    address public technicalAndOperationalReserve;\n\n    // Events\n    event Received(address, uint);\n    \n    // Constructor\n    constructor (\n        string memory name,\n        string memory symbol,\n        uint _initialSupply,\n        address _saleReserve,\n        address _technicalAndOperationalReserve          \n    ) payable ERC20 (name, symbol) {\n        saleReserve = _saleReserve;\n        technicalAndOperationalReserve = _technicalAndOperationalReserve;\n        if (_initialSupply \u003e 0) {\n            require((_initialSupply % 10) == 0, \"_initialSupply has to be a multiple of 10!\");\n            uint eightyFivePerCent = _initialSupply * 85 / 100;\n            uint fifteenPerCent = _initialSupply * 15 / 100; \n            mint(saleReserve, fifteenPerCent); \n            mint(technicalAndOperationalReserve, eightyFivePerCent);       \n            mintingFinished = true;\n        }\n    }\n\n    // Receive function \n    receive() external payable {\n        emit Received(msg.sender, msg.value);\n    }\n\n    // External functions\n    function withdraw() external onlyOwner {\n        require(address(this).balance \u003e 0, \"Insuficient funds!\");\n        uint amount = address(this).balance;\n        // sending to prevent re-entrancy attacks\n        address(this).balance - amount;\n        payable(msg.sender).transfer(amount);\n    }\n    \n    // Public functions\n    function mint(address account, uint amount) public onlyOwner canMint {\n        _mint(account, amount);\n    }\n}\n"},"CoinvestingDeFiTokenSale.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\npragma solidity \u003e=0.8.0 \u003c0.9.0;\n\nimport \"./CoinvestingDeFiToken.sol\";\nimport \"./Ownable.sol\";\n\ncontract CoinvestingDeFiTokenSale is Ownable {\n    // Public variables\n    CoinvestingDeFiToken public tokenContract;\n    uint public bonusLevelOne = 50;\n    uint public bonusLevelTwo = 35;\n    uint public bonusLevelThree = 20;\n    uint public bonusLevelFour = 5;\n    uint public calculatedBonus;    \n    uint public levelOneDate;\n    uint public levelTwoDate;\n    uint public levelThreeDate;\n    uint public levelFourDate;\n    uint public tokenBonus;\n    uint public tokenPrice;\n    uint public tokenSale;\n    uint public tokensSold;\n    \n    // Internal variables\n    bool internal contractSeted = false;\n\n    // Events\n    event Received(address, uint);\n    event Sell(address _buyer, uint _amount);\n    event SetPercents(uint _bonusLevelOne, uint _bonusLevelTwo, uint _bonusLevelThree, uint _bonusLevelFour);\n    \n    // Modifiers\n    modifier canContractSet() {\n        require(!contractSeted, \"Set contract token is not allowed!\");\n        _;\n    }\n\n    // Constructor\n    constructor(uint _levelOneDate, uint _levelTwoDate, uint _levelThreeDate, uint _levelFourDate) payable {\n        levelOneDate = _levelOneDate * 1 seconds;\n        levelTwoDate = _levelTwoDate * 1 days;\n        levelThreeDate = _levelThreeDate * 1 days;\n        levelFourDate = _levelFourDate * 1 days;\n    }\n\n    // Receive function\n    receive() external payable {\n        emit Received(msg.sender, msg.value);\n    }\n\n    // External functions\n    function endSale() external onlyOwner {\n        require(\n            tokenContract.transfer(\n                msg.sender,\n                tokenContract.balanceOf(address(this))\n            ),\n            \"Unable to transfer tokens to admin!\"\n        );\n        // destroy contract\n        payable(msg.sender).transfer(address(this).balance);\n        contractSeted = false;\n    }\n\n    function setTokenContract(CoinvestingDeFiToken _tokenContract) external onlyOwner canContractSet {\n        tokenContract = _tokenContract;\n        contractSeted = true;\n        tokenBonus = tokenContract.balanceOf(address(this)) / 3;\n        tokenSale = tokenContract.balanceOf(address(this)) - tokenBonus;        \n    }\n\n    function setPercents(\n        uint _bonusLevelOne,\n        uint _bonusLevelTwo,\n        uint _bonusLevelThree,\n        uint _bonusLevelFour\n    ) \n    external \n    onlyOwner {\n        require(_bonusLevelOne \u003c= 50, \"L1 - Maximum 50 %.\");\n        require(_bonusLevelTwo \u003c= bonusLevelOne, \"L2 - The maximum value must be the current L1.\");\n        require(_bonusLevelThree \u003c= bonusLevelTwo, \"L3 - The maximum value must be the current L2.\");\n        require(_bonusLevelFour \u003c= bonusLevelThree, \"L4 - The maximum value must be the current L3.\");\n        bonusLevelOne = _bonusLevelOne;\n        bonusLevelTwo = _bonusLevelTwo;\n        bonusLevelThree = _bonusLevelThree;\n        bonusLevelFour = _bonusLevelFour;\n        emit SetPercents(bonusLevelOne, bonusLevelTwo, bonusLevelThree, bonusLevelFour);\n    }\n\n    function withdraw() external onlyOwner {\n        require(address(this).balance \u003e 0, \"Insuficient funds!\");\n        uint amount = address(this).balance;\n        // sending to prevent re-entrancy attacks\n        address(this).balance - amount;\n        payable(msg.sender).transfer(amount);\n    }\n\n    // External functions that are view\n    function getBalance() external view returns(uint) {\n        return address(this).balance;\n    }\n\n    function getTokenBonusBalance() external view returns(uint) {\n        return tokenBonus;\n    }\n\n    function getTokenSaleBalance() external view returns(uint) {\n        return tokenSale;\n    }\n\n    function getPercents() \n    external \n    view \n    returns(\n        uint levelOne,\n        uint levelTwo,\n        uint levelThree,\n        uint levelFour)\n    {\n        levelOne = bonusLevelOne;\n        levelTwo = bonusLevelTwo;\n        levelThree = bonusLevelThree;\n        levelFour = bonusLevelFour;\n    }\n\n    // Public functions\n    function buyTokens(uint _numberOfTokens, uint _tokenPrice) public payable {\n        if (block.timestamp \u003c= levelOneDate + levelTwoDate) {\n            calculatedBonus = _numberOfTokens * bonusLevelOne / 100;\n        }\n        else if (block.timestamp \u003c= levelOneDate + levelTwoDate + levelThreeDate) {\n            calculatedBonus = _numberOfTokens * bonusLevelTwo / 100;\n        }\n        else if (block.timestamp \u003c= levelOneDate + levelTwoDate + levelThreeDate + levelFourDate) {\n            calculatedBonus = _numberOfTokens * bonusLevelThree / 100;\n        }\n        else {\n            calculatedBonus = _numberOfTokens * bonusLevelFour / 100;\n        }\n\n        require(\n            msg.value == _numberOfTokens * _tokenPrice,\n            \"Number of tokens does not match with the value!\"\n        );\n            \n        uint scaledAmount = (calculatedBonus + _numberOfTokens) * 10 ** tokenContract.decimals();\n        require(\n            tokenSale \u003e= _numberOfTokens * 10 ** tokenContract.decimals(),\n            \"The contract does not have enough TOKENS!\"\n        );\n\n        require(\n            tokenBonus \u003e= calculatedBonus * 10 ** tokenContract.decimals(),\n            \"The contract does not have enough BONUS tokens!\"\n        );\n\n        tokensSold += _numberOfTokens;\n        tokenSale -= _numberOfTokens * 10 ** tokenContract.decimals();\n        tokenBonus -= calculatedBonus * 10 ** tokenContract.decimals();\n        emit Sell(msg.sender, _numberOfTokens);\n        require(\n            tokenContract.transfer(payable(msg.sender), scaledAmount),\n            \"Some problem with token transfer!\"\n        );        \n    }\n}\n"},"Context.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\npragma solidity \u003e=0.8.0 \u003c0.9.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return payable(msg.sender);\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"},"ERC20.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\npragma solidity \u003e=0.8.0 \u003c0.9.0;\n\nimport \"./Context.sol\";\nimport \"./IERC20.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin guidelines: functions revert instead\n * of returning `false` on failure. This behavior is nonetheless conventional\n * and does not conflict with the expectations of ERC20 applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20 is Context, IERC20 {\n\n    bool internal mintingFinished = false;\n\n    modifier canMint() {\n        require(!mintingFinished, \"Creating new tokens is not allowed.\");\n        _;\n    }\n\n    mapping (address =\u003e uint) private _balances;\n\n    mapping (address =\u003e mapping (address =\u003e uint)) private _allowances;\n\n    uint private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with\n     * a default value of 18.\n     *\n     * To select a different value for {decimals}, use {_setupDecimals}.\n     *\n     * All three of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor (string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n        _decimals = 18;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is\n     * called.\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view returns (uint8) {\n        return _decimals;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view override returns (uint) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view override returns (uint) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `recipient` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address recipient, uint amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual override returns (uint) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * Requirements:\n     *\n     * - `sender` and `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``sender``\u0027s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);\n        return true;\n    }\n\n    /**\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\n     *\n     * This is internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `sender` cannot be the zero address.\n     * - `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     */\n    function _transfer(address sender, address recipient, uint amount) internal virtual {\n        require(sender != address(0), \"Transfer from the zero address not allowed.\");\n        require(recipient != address(0), \"Transfer to the zero address not allowed.\");\n\n        _beforeTokenTransfer(sender, recipient, amount);\n\n        _balances[sender] = _balances[sender] - amount;\n        _balances[recipient] = _balances[recipient] + amount;\n        emit Transfer(sender, recipient, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     */\n    function _mint(address account, uint amount) internal virtual {\n        require(account != address(0), \"Mint to the zero address not allowed.\");\n\n        _beforeTokenTransfer(address(0), account, amount);\n\n        _totalSupply = _totalSupply + amount;\n        _balances[account] = _balances[account] + amount;\n        emit Transfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(address owner, address spender, uint amount) internal virtual {\n        require(owner != address(0), \"Approve from the zero address not allowed.\");\n        require(spender != address(0), \"Approve to the zero address not allowed.\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * will be to transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual { }\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\npragma solidity \u003e=0.8.0 \u003c0.9.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint value);\n\n    event MintFinished();\n}\n"},"MultiSigWallet.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\npragma solidity \u003e=0.8.0 \u003c0.9.0;\n\nimport \"./CoinvestingDeFiToken.sol\";\nimport \"./Ownable.sol\";\n\ncontract MultiSigWallet is Ownable{\n    // Types\n    enum Authorization {\n        NONE,\n        OWNER,\n        DEACTIVATED\n    }\n\n    struct Transaction {\n        uint id; \n        uint amount;\n        address payable to;\n        address tokenContract;\n        address createdBy;\n        uint signatureCount;\n        bool completed;\n    }\n\n    // Public variables\n    CoinvestingDeFiToken public tokenContract;\n    uint public constant quorum = 2;\n\n    // Internal variables\n    bool internal contractSeted = false;\n\n    // Private variables\n    uint private nextTransactionId;\n    uint[] private _pendingTransactions;\n    uint[] private completed;\n    address private _admin;\n\n    // Mappings\n    mapping(address =\u003e Authorization) private owners;\n    mapping(uint =\u003e Transaction) transactions;\n    mapping(uint =\u003e mapping(address =\u003e bool)) signatures;\n\n    // Modifiers\n    modifier canContractSet() {\n        require(!contractSeted, \"Set contract token is not allowed!\");\n        _;\n    }\n\n    modifier isValidOwner() {\n        require(owners[msg.sender] == Authorization.OWNER,\n        \"You must have owner authorization to create transaction!\");\n        _;\n    }\n\n    // Events\n    event TransactionCreated(uint nextTransactionId, address createdBy, address to,  uint amount);\n    event TransactionCompleted(uint transactionId, address to, uint amount, address createdBy, address executedBy);\n    event TransactionSigned(uint transactionId, address signer);\n    event NewOwnerAdded(address newOwner);\n    event FundsDeposited(address from, uint amount);\n\n    // Constructor\n    constructor() payable {\n        _admin = msg.sender;\n        owners[msg.sender] = Authorization.OWNER;\n    }\n\n    // Receive function\n    receive() external payable{\n        emit FundsDeposited(msg.sender, msg.value);\n    }\n\n    // External functions\n    function activateOwner(address addr) external onlyOwner {\n        require(addr != address(0), \"Invalid address!\");\n        owners[addr] = Authorization.OWNER;\n    }\n\n    function addOwner(address newOwner) external onlyOwner {\n        require(newOwner != address(0), \"Invalid address!\");\n        require(owners[newOwner] == Authorization.NONE, \"Address already an owner!\");\n        owners[newOwner] = Authorization.OWNER;\n        emit NewOwnerAdded(newOwner);\n    }\n\n    function createTransfer(uint amount, address payable to) external isValidOwner {\n        nextTransactionId++;  \n         \n        transactions[nextTransactionId]= Transaction({\n            id:nextTransactionId,\n            amount: amount,\n            to: to,\n            tokenContract: address(tokenContract),\n            createdBy: msg.sender,\n            signatureCount: 0,\n            completed: false\n        });\n\n        _pendingTransactions.push(nextTransactionId);\n        emit TransactionCreated(nextTransactionId, msg.sender, to, amount);\n    }\n\n    function deactivateOwner(address addr) external onlyOwner {\n        require(addr != address(0), \"Invalid address!\");\n        owners[addr] = Authorization.DEACTIVATED;\n    }\n\n    function executeTransaction(uint id) external isValidOwner {\n        require(transactions[id].to != address(0),\n        \"Transaction does not exist!\");\n        require(transactions[id].completed == false,\n        \"Transactions has already been completed!\");\n        require(transactions[id].signatureCount \u003e= quorum,\n        \"Transaction requires more signatures!\");\n        require(tokenContract.balanceOf(address(this)) \u003e= transactions[id].amount,\n        \"Insufficient balance.\");\n\n        transactions[id].completed = true;\n        address payable to = transactions[id].to;\n        uint amount = transactions[id].amount;\n        tokenContract.transfer(to, amount);\n        completed.push(id);\n        emit TransactionCompleted(id, to, amount, transactions[id].createdBy, msg.sender);\n    }\n         \n    function setTokenContract(CoinvestingDeFiToken _tokenContract) external onlyOwner canContractSet {\n        tokenContract = _tokenContract;\n        contractSeted = true;\n    }\n\n    function signTransation(uint id) external isValidOwner {\n        require(transactions[id].to != address(0),\n        \"Transaction does not exist!\");\n        require(transactions[id].createdBy != msg.sender,\n        \"Transaction creator cannot sign transaction!\");\n        require(signatures[id][msg.sender] == false,\n        \"Cannot sign transaction more than once!\");\n        \n        Transaction storage transaction = transactions[id];\n        signatures[id][msg.sender] = true;\n        transaction.signatureCount++; \n        emit TransactionSigned(id, msg.sender);\n    }\n\n    function withdraw() external onlyOwner {\n        require(address(this).balance \u003e 0, \"Insuficient funds!\");\n        uint amount = address(this).balance;\n        // sending to prevent re-entrancy attacks\n        address(this).balance - amount;\n        payable(msg.sender).transfer(amount);\n    }\n\n    // External functions that are view\n    function getBalance() external view returns(uint) {\n        return address(this).balance;\n    }\n\n    function getPendingTransactions() external view returns(uint[] memory){\n        return _pendingTransactions;\n    }\n\n    function getCompletedTransactions() public view returns(uint[] memory){\n        return completed;\n    }\n\n    function getTokenBalance() external view returns(uint) {\n        return tokenContract.balanceOf(address(this));\n    }\n\n    function getTransactionSignatureCount(uint transactionId) external view returns(uint) {\n        require(transactions[transactionId].to != address(0),\n        \"Transaction does not exist!\");\n        return transactions[transactionId].signatureCount;\n    }\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\npragma solidity \u003e=0.8.0 \u003c0.9.0;\n\nimport \"./Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(_owner == _msgSender(), \"The caller is not the owner.\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"New owner is the zero address.\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"}}