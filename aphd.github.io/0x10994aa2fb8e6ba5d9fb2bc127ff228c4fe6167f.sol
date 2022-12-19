{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.7.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () { }\r\n\r\n    function _msgSender() internal view virtual returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"./Context.sol\";\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.7.0;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, reverts on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    uint256 c = a * b;\r\n    require(c / a == b);\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b \u003e 0); // Solidity only automatically asserts when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b \u003c= a);\r\n    uint256 c = a - b;\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, reverts on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a + b;\r\n    require(c \u003e= a);\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n  * reverts when dividing by zero.\r\n  */\r\n  function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b != 0);\r\n    return a % b;\r\n  }\r\n}"},"SEPA_Token.sol":{"content":"/* \r\n   SPDX-License-Identifier: MIT\r\n*/\r\n\r\ninterface IUniswapV2Factory {\r\n    function createPair(address tokenA, address tokenB) external returns (address pair);\r\n}\r\n\r\ninterface IUniswapV2Pair {\r\n    function sync() external;\r\n}\r\n\r\ninterface IUniswapV2Router01 {\r\n    function factory() external pure returns (address);\r\n    function WETH() external pure returns (address);\r\n    function addLiquidity(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint amountADesired,\r\n        uint amountBDesired,\r\n        uint amountAMin,\r\n        uint amountBMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountA, uint amountB, uint liquidity);\r\n    function addLiquidityETH(\r\n        address token,\r\n        uint amountTokenDesired,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);\r\n}\r\n\r\ninterface IUniswapV2Router02 is IUniswapV2Router01 {\r\n    function removeLiquidityETHSupportingFeeOnTransferTokens(\r\n      address token,\r\n      uint liquidity,\r\n      uint amountTokenMin,\r\n      uint amountETHMin,\r\n      address to,\r\n      uint deadline\r\n    ) external returns (uint amountETH);\r\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n    function swapExactETHForTokensSupportingFeeOnTransferTokens(\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external payable;\r\n}\r\n\r\npragma solidity ^0.7.0;\r\n\r\nimport \"../SafeMath.sol\";\r\nimport \"../Ownable.sol\";\r\n\r\ncontract SEPA_Token is Ownable\r\n{\r\n    using SafeMath for *;\r\n\r\n\tIUniswapV2Router02 public _uniswapV2Router;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    address public reserve_repay_addr;\r\n\r\n    mapping (address =\u003e uint256) private _balances;\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\r\n\r\n    mapping(address =\u003e bool) public uniswapPairAddress;\r\n\taddress public currentPoolAddress;\r\n\taddress public currentPairTokenAddress;\r\n\taddress public uniswapETHPool;\r\n\r\n    uint16 public LP_FEE = 3;\r\n    uint16 public RR_FEE = 1;\r\n    \r\n    bool public transferable = false;\r\n    mapping (address =\u003e bool) public transferWhitelist;\r\n\r\n\tuint256 public _minTokensBeforeSwap = 100;\r\n\tuint256 constant _autoSwapCallerFee = 0;\r\n\tuint256 constant liquidityRewardRate = 2;\r\n\t\r\n\tbool private inSwapAndLiquify;\r\n    bool public swapAndLiquifyEnabled;\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint amount);\r\n    event Approval(address indexed owner, address indexed spender, uint amount);\r\n    event UniswapPairAddress(address _addr, bool _whitelisted);\r\n\t\r\n\tevent MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);\r\n    event SwapAndLiquifyEnabledUpdated(bool enabled);\r\n    event SwapAndLiquify(\r\n        address indexed pairTokenAddress,\r\n        uint256 tokensSwapped,\r\n        uint256 pairTokenReceived,\r\n        uint256 tokensIntoLiqudity\r\n    );\r\n    \r\n\tmodifier lockTheSwap {\r\n        inSwapAndLiquify = true;\r\n        _;\r\n        inSwapAndLiquify = false;\r\n    }\r\n\r\n    constructor (IUniswapV2Router02 uniswapV2Router) {\r\n        _name = \"Secure Pad\";\r\n        _symbol = \"SEPA\";\r\n        _decimals = 18;\r\n        _mint(msg.sender, 3.5e5 * 10**_decimals); \r\n        _minTokensBeforeSwap = 100 * 10**_decimals;\r\n        \r\n\t\t_uniswapV2Router = uniswapV2Router;\r\n\r\n        currentPoolAddress = IUniswapV2Factory(uniswapV2Router.factory())\r\n            .createPair(address(this), uniswapV2Router.WETH());\r\n            \r\n        uniswapETHPool = currentPoolAddress;\r\n        \r\n        transferWhitelist[msg.sender] = true;\r\n\r\n    }\r\n    \r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n\r\n    function totalSupply() public view  returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function balanceOf(address account) public view  returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    function transfer(address recipient, uint256 amount) public virtual  returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address owner, address spender) public view virtual  returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    function approve(address spender, uint256 amount) public virtual  returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual  returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));\r\n        return true;\r\n    }\r\n    \r\n\r\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\t\r\n\tfunction _transfer(address sender, address recipient, uint256 amount) private {\r\n\t\trequire(sender != address(0), \"cannot transfer from the zero address\");\r\n        require(recipient != address(0), \"cannot transfer to the zero address\");\r\n\r\n        if (!transferable) {\r\n            require(transferWhitelist[sender], \"sender not in transfer whitelist\");\r\n        }\r\n\r\n        if(!inSwapAndLiquify) {\r\n            uint256 lockedBalanceForPool = balanceOf(address(this));\r\n            bool overMinTokenBalance = lockedBalanceForPool \u003e= _minTokensBeforeSwap;\r\n\t\t\tcurrentPairTokenAddress == _uniswapV2Router.WETH();\r\n            if (\r\n                overMinTokenBalance \u0026\u0026\r\n                msg.sender != currentPoolAddress \u0026\u0026\r\n                swapAndLiquifyEnabled \u0026\u0026\r\n                _isUniswapPairAddress(recipient)\r\n            ) {\r\n                swapAndLiquifyForEth(lockedBalanceForPool);\r\n            }\r\n        }\r\n            _transferStandard(sender, recipient, amount);\r\n    }\r\n    \r\n\tfunction _transferStandard(address sender, address recipient, uint256 amount) private {\r\n\t\t_balances[sender] = _balances[sender].sub(amount);\r\n\t\t\r\n\t\tif (inSwapAndLiquify) {\r\n            _balances[recipient] = _balances[recipient].add(amount);\r\n            emit Transfer(sender, recipient, amount);\r\n\t\t}\r\n\t\t\r\n\t    else if (_isUniswapPairAddress(recipient))\r\n        {\r\n        uint256 LP_amount = LP_FEE.mul(amount).div(100);\r\n        uint256 RR_amount = RR_FEE.mul(amount).div(100);\r\n        uint256 transfer_amount = amount.sub(LP_amount.add(RR_amount));\r\n\r\n\t\t_transferStandardSell(sender, recipient, transfer_amount, LP_amount, RR_amount);\r\n        }\r\n        \r\n        else {\r\n            _balances[recipient] = _balances[recipient].add(amount);\r\n            emit Transfer(sender, recipient, amount);\r\n\r\n        }\r\n    }\r\n    \r\n    function _transferStandardSell(address sender, address recipient, uint256 transfer_amount, uint256 LP_amount, uint256 RR_amount) private {\r\n            _balances[recipient] = _balances[recipient].add(transfer_amount);\r\n            _balances[address(this)] = _balances[address(this)].add(LP_amount);\r\n            _balances[reserve_repay_addr] = _balances[reserve_repay_addr].add(RR_amount);        \r\n\t\t\r\n            emit Transfer(sender, recipient, transfer_amount);\r\n            emit Transfer(sender, address(this), LP_amount);\r\n            emit Transfer(sender, reserve_repay_addr, RR_amount);\r\n    }\r\n    \r\n    function swapAndLiquifyForEth(uint256 lockedBalanceForPool) internal lockTheSwap {\r\n        uint256 lockedForSwap = lockedBalanceForPool.sub(_autoSwapCallerFee);\r\n\t\tuint256 forLiquidity = lockedForSwap.div(liquidityRewardRate);\r\n\t\tuint256 forLiquidityReward = lockedForSwap.sub(forLiquidity);\r\n        uint256 half = forLiquidity.div(2);\r\n        uint256 otherHalf = forLiquidity.sub(half);\r\n\r\n        uint256 initialBalance = address(this).balance;\r\n\r\n        swapTokensForEth(half);\r\n        \r\n        uint256 newBalance = address(this).balance.sub(initialBalance);\r\n\r\n        addLiquidityForEth(otherHalf, newBalance);\r\n        \r\n        emit SwapAndLiquify(_uniswapV2Router.WETH(), half, newBalance, otherHalf);\r\n        \r\n\t\t_transfer(address(this), uniswapETHPool, forLiquidityReward);\r\n        _transfer(address(this), tx.origin, _autoSwapCallerFee);\r\n    }\r\n    \r\n    function swapTokensForEth(uint256 tokenAmount) internal {\r\n        address[] memory path = new address[](2);\r\n        path[0] = address(this);\r\n        path[1] = _uniswapV2Router.WETH();\r\n\r\n        _approve(address(this), address(_uniswapV2Router), tokenAmount);\r\n\r\n        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n            tokenAmount,\r\n            0, // accept any amount of ETH\r\n            path,\r\n            address(this),\r\n            block.timestamp\r\n        );\r\n    }\r\n\r\n    function addLiquidityForEth(uint256 tokenAmount, uint256 ethAmount) internal {\r\n        _approve(address(this), address(_uniswapV2Router), tokenAmount);\r\n\r\n        _uniswapV2Router.addLiquidityETH{value: ethAmount}(\r\n            address(this),\r\n            tokenAmount,\r\n            0, // slippage is unavoidable\r\n            0, // slippage is unavoidable\r\n            address(this),\r\n            block.timestamp\r\n        );\r\n    }\r\n\r\n\treceive() external payable {}\r\n\r\n \tfunction _setMinTokensBeforeSwap(uint256 minTokensBeforeSwap) external onlyOwner() {\r\n        require(minTokensBeforeSwap \u003e= 1 * _decimals, \u0027minTokenBeforeSwap should be greater than 1 SEPA\u0027);\r\n        _minTokensBeforeSwap = minTokensBeforeSwap;\r\n        emit MinTokensBeforeSwapUpdated(minTokensBeforeSwap);\r\n    }\r\n    \r\n    function _enableTransfers() external onlyOwner() {\r\n        transferable = true;\r\n    }\r\n    \r\n    function _isUniswapPairAddress(address _addr) internal view returns (bool) {\r\n        return uniswapPairAddress[_addr];\r\n    }\r\n    \r\n    function _setUniswapPairAddress(address _addr, bool _whitelisted) external onlyOwner {\r\n        emit UniswapPairAddress(_addr, _whitelisted);\r\n        uniswapPairAddress[_addr] = _whitelisted;\r\n    }\r\n    \r\n    function _setReserveRepayAddr(address _addr) external onlyOwner {\r\n        reserve_repay_addr = _addr;\r\n    }\r\n    \r\n    function _setRouterContract(IUniswapV2Router02 _addr) external onlyOwner {\r\n        _uniswapV2Router = _addr;\r\n    }\r\n\r\n    function _mint(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    function _burn(uint256 amount) public {\r\n        require(msg.sender != address(0), \"ERC20: burn from the zero address\");\r\n\r\n        _balances[msg.sender] = _balances[msg.sender].sub(amount);\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(msg.sender, address(0), amount);\r\n    }\r\n\t\r\n\tfunction getCurrentPoolAddress() public view returns(address) {\r\n        return currentPoolAddress;\r\n    }\r\n    \r\n    function getCurrentPairTokenAddress() public view returns(address) {\r\n        return currentPairTokenAddress;\r\n    }\r\n\r\n\tfunction updateSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {\r\n        swapAndLiquifyEnabled = _enabled;\r\n        emit SwapAndLiquifyEnabledUpdated(_enabled);\r\n    }\r\n    \r\n    function setAddrTransferWhitelist(address _addr, bool _bool) external onlyOwner {\r\n        transferWhitelist[_addr] = _bool;\r\n    }\r\n    \r\n    function setFees(uint16 lp, uint16 rr) external onlyOwner {\r\n        LP_FEE = lp;\r\n        RR_FEE = rr;\r\n    }\r\n\t\r\n}"}}