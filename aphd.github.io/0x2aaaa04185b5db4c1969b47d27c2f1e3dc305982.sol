{"EarlyBirdV2.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n// VokenTB (TeraByte) EarlyBird-Sale\r\n//\r\n// More info:\r\n//   https://voken.io\r\n//\r\n// Contact us:\r\n//   support@voken.io\r\n\r\n\r\nimport \"LibSafeMath.sol\";\r\nimport \"LibIERC20.sol\";\r\nimport \"LibIVesting.sol\";\r\nimport \"LibIVokenTB.sol\";\r\nimport \"LibAuthPause.sol\";\r\nimport \"EbWithVestingPermille.sol\";\r\n\r\n\r\ninterface IUniswapV2Router02 {\r\n    function WETH() external pure returns (address);\r\n    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);\r\n    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)\r\n        external\r\n        payable\r\n        returns (uint[] memory amounts);\r\n}\r\n\r\n\r\n/**\r\n * @dev EarlyBird-Sale v2\r\n */\r\ncontract EarlyBirdSaleV2 is AuthPause, IVesting, WithVestingPermille {\r\n    using SafeMath for uint256;\r\n\r\n    uint256 private immutable VOKEN_ISSUE_MAX = 21_000_000e9;  // 21 million for early-birds\r\n    uint256 private immutable VOKEN_ISSUE_MID = 10_500_000e9;\r\n    uint256 private immutable WEI_PAYMENT_MAX = 5.0 ether;\r\n    uint256 private immutable WEI_PAYMENT_MID = 3.0 ether;\r\n    uint256 private immutable WEI_PAYMENT_MIN = 0.1 ether;\r\n    uint256 private immutable USD_PRICE_START = 0.5e6;  // $ 0.5 USD\r\n    uint256 private immutable USD_PRICE_DISTA = 0.4e6;  // $ 0.4 USD = 0.9 - 0.5\r\n    uint256 private _vokenIssued;\r\n    uint256 private _vokenRandom;\r\n\r\n    IUniswapV2Router02 private immutable UniswapV2Router02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);\r\n    IVokenTB private immutable VOKEN_TB = IVokenTB(0x1234567a022acaa848E7D6bC351d075dBfa76Dd4);\r\n    IERC20 private immutable DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);\r\n\r\n    struct Account {\r\n        uint256 issued;\r\n        uint256 bonuses;\r\n        uint256 referred;\r\n        uint256 rewards;\r\n    }\r\n\r\n    mapping (address =\u003e Account) private _accounts;\r\n\r\n    event Payment(address indexed account, uint256 daiAmount, uint256 issued, uint256 random);\r\n    event Reward(address indexed account, address indexed referrer, uint256 amount);\r\n    \r\n\r\n    constructor () {\r\n        _vokenIssued = 344506165000000;\r\n        _vokenRandom = 19157979970000;\r\n    }\r\n\r\n    receive()\r\n        external\r\n        payable\r\n    {\r\n        _swap();\r\n    }\r\n\r\n    function swap()\r\n        external\r\n        payable\r\n    {\r\n        _swap();\r\n    }\r\n\r\n    function status()\r\n        public\r\n        view\r\n        returns (\r\n            uint256 vokenCap,\r\n            uint256 vokenTotalSupply,\r\n\r\n            uint256 vokenIssued,\r\n            uint256 vokenRandom,\r\n            uint256 etherUSD,\r\n            uint256 vokenUSD,\r\n            uint256 weiMin,\r\n            uint256 weiMax\r\n        )\r\n    {\r\n        vokenCap = VOKEN_TB.cap();\r\n        vokenTotalSupply = VOKEN_TB.totalSupply();\r\n\r\n        vokenIssued = _vokenIssued;\r\n        vokenRandom = _vokenRandom;\r\n        etherUSD = etherUSDPrice();\r\n        vokenUSD = vokenUSDPrice();\r\n\r\n        weiMin = WEI_PAYMENT_MIN;\r\n        weiMax = _vokenIssued \u003c VOKEN_ISSUE_MID ? WEI_PAYMENT_MAX : WEI_PAYMENT_MID;\r\n    }\r\n\r\n    function getAccountStatus(address account)\r\n        public\r\n        view\r\n        returns (\r\n            uint256 issued,\r\n            uint256 bonuses,\r\n            uint256 referred,\r\n            uint256 rewards,\r\n\r\n            uint256 etherBalance,\r\n            uint256 vokenBalance,\r\n\r\n            uint160 voken,\r\n            address referrer,\r\n            uint160 referrerVoken\r\n        )\r\n    {\r\n        issued = _accounts[account].issued;\r\n        bonuses = _accounts[account].bonuses;\r\n        referred = _accounts[account].referred;\r\n        rewards = _accounts[account].referred;\r\n\r\n        etherBalance = account.balance;\r\n        vokenBalance = VOKEN_TB.balanceOf(account);\r\n        \r\n        voken = VOKEN_TB.address2voken(account);\r\n        referrer = VOKEN_TB.referrer(account);\r\n\r\n        if (referrer != address(0)) {\r\n            referrerVoken = VOKEN_TB.address2voken(referrer);\r\n        }\r\n    }\r\n\r\n    function vestingOf(address account)\r\n        public\r\n        override\r\n        view\r\n        returns (uint256 vesting)\r\n    {\r\n        vesting = vesting.add(_getVestingAmountForIssued(_accounts[account].issued));\r\n        vesting = vesting.add(_getVestingAmountForBonuses(_accounts[account].bonuses));\r\n        vesting = vesting.add(_getVestingAmountForRewards(_accounts[account].rewards));\r\n    }\r\n\r\n    function vokenUSDPrice()\r\n        public\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return USD_PRICE_START.add(USD_PRICE_DISTA.mul(_vokenIssued).div(VOKEN_ISSUE_MAX));\r\n    }\r\n    \r\n    function daiTransfer(address to, uint256 amount)\r\n        external\r\n        onlyAgent\r\n    {\r\n        DAI.transfer(to, amount);\r\n    }\r\n\r\n    function _swap()\r\n        private\r\n        onlyNotPaused\r\n    {\r\n        require(msg.value \u003e= WEI_PAYMENT_MIN, \"Insufficient ether\");\r\n        require(_vokenIssued \u003c VOKEN_ISSUE_MAX, \"Early-Bird sale completed\");\r\n        require(_accounts[msg.sender].issued == 0, \"Caller is already an early-bird\");\r\n\r\n        uint256 weiPayment = msg.value;\r\n        uint256 weiPaymentMax = _vokenIssued \u003c VOKEN_ISSUE_MID ? WEI_PAYMENT_MAX : WEI_PAYMENT_MID;\r\n\r\n        // Limit the Payment and Refund (if needed)\r\n        if (weiPayment \u003e weiPaymentMax)\r\n        {\r\n            msg.sender.transfer(weiPayment.sub(weiPaymentMax));\r\n            weiPayment = weiPaymentMax;\r\n        }\r\n\r\n        uint256 daiAmount = _swapExactETH2DAI(weiPayment);\r\n        uint256 vokenIssued = daiAmount.div(1e3).div(vokenUSDPrice());\r\n        uint256 vokenRandom;\r\n\r\n        // Voken Bonus \u0026 Ether Rewards\r\n        address payable referrer = VOKEN_TB.referrer(msg.sender);\r\n        if (referrer != address(0))\r\n        {\r\n            // Reffer\r\n            _accounts[referrer].referred = _accounts[referrer].referred.add(daiAmount);\r\n\r\n            // Voken Random: 1% - 10%\r\n            vokenRandom = vokenIssued.mul(uint256(blockhash(block.number - 1)).mod(10).add(1)).div(100);\r\n            emit Reward(msg.sender, referrer, vokenRandom);\r\n\r\n            _vokenRandom = _vokenRandom.add(vokenRandom.mul(2));\r\n            _accounts[msg.sender].bonuses = _accounts[msg.sender].bonuses.add(vokenRandom);\r\n            _accounts[referrer].rewards = _accounts[referrer].rewards.add(vokenRandom);\r\n\r\n            // VOKEN_TB.mintWithVesting(msg.sender, vokenRandom, address(this));\r\n            VOKEN_TB.mintWithVesting(referrer, vokenRandom, address(this));\r\n        }\r\n\r\n        _vokenIssued = _vokenIssued.add(vokenIssued);\r\n        _accounts[msg.sender].issued = _accounts[msg.sender].issued.add(vokenIssued);\r\n        \r\n        // Issued + Random\r\n        VOKEN_TB.mintWithVesting(msg.sender, vokenIssued.add(vokenRandom), address(this));\r\n\r\n        // Payment Event\r\n        emit Payment(msg.sender, daiAmount, vokenIssued, vokenRandom);\r\n    }\r\n\r\n    function etherUSDPrice()\r\n        public\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return UniswapV2Router02.getAmountsOut(1_000_000, _pathETH2DAI())[1];\r\n    }\r\n\r\n    function _swapExactETH2DAI(uint256 etherAmount)\r\n        private\r\n        returns (uint256)\r\n    {\r\n        uint256[] memory _result = UniswapV2Router02.swapExactETHForTokens{value: etherAmount}(0, _pathETH2DAI(), address(this), block.timestamp + 1 days);\r\n        return _result[1];\r\n    }\r\n\r\n    function _pathETH2DAI()\r\n        private\r\n        view\r\n        returns (address[] memory)\r\n    {\r\n        address[] memory path = new address[](2);\r\n        path[0] = UniswapV2Router02.WETH();\r\n        path[1] = address(DAI);\r\n        return path;\r\n    }\r\n}\r\n"},"EbWithVestingPermille.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n\r\nimport \"LibSafeMath.sol\";\r\nimport \"LibBaseAuth.sol\";\r\nimport \"LibIPermille.sol\";\r\n\r\n\r\ncontract WithVestingPermille is BaseAuth {\r\n    using SafeMath for uint256;\r\n    \r\n    IPermille private _issuedVestingPermilleContract;\r\n    IPermille private _bonusesVestingPermilleContract;\r\n    IPermille private _rewardsVestingPermilleContract;\r\n\r\n    /**\r\n     * @dev Set Vesting Permille Contract(s).\r\n     */\r\n    function setIVPC(address issuedVestingPermilleContract)\r\n        external\r\n        onlyAgent\r\n    {\r\n        _issuedVestingPermilleContract = IPermille(issuedVestingPermilleContract);\r\n    }\r\n\r\n    function setBVPC(address bonusesVestingPermilleContract)\r\n        external\r\n        onlyAgent\r\n    {\r\n        _bonusesVestingPermilleContract = IPermille(bonusesVestingPermilleContract);\r\n    }\r\n\r\n    function setRVPC(address rewardsVestingPermilleContract)\r\n        external\r\n        onlyAgent\r\n    {\r\n        _rewardsVestingPermilleContract = IPermille(rewardsVestingPermilleContract);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the Vesting Permille Contract(s).\r\n     */\r\n    function VestingPermilleContracts()\r\n        public\r\n        view\r\n        returns (\r\n            IPermille issuedVestingPermilleContract,\r\n            IPermille bonusesVestingPermilleContract,\r\n            IPermille rewardsVestingPermilleContract\r\n        )\r\n    {\r\n        issuedVestingPermilleContract = _issuedVestingPermilleContract;\r\n        bonusesVestingPermilleContract = _bonusesVestingPermilleContract;\r\n        rewardsVestingPermilleContract = _rewardsVestingPermilleContract;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns vesting amount for issued of `amount`.\r\n     */\r\n    function _getVestingAmountForIssued(uint256 amount)\r\n        internal\r\n        view\r\n        returns (uint256 vesting)\r\n    {\r\n        if (amount \u003e 0) {\r\n            vesting = _getVestingAmount(amount, _issuedVestingPermilleContract, 900);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns vesting amount for bonuses of `amount`.\r\n     */\r\n    function _getVestingAmountForBonuses(uint256 amount)\r\n        internal\r\n        view\r\n        returns (uint256 vesting)\r\n    {\r\n        if (amount \u003e 0) {\r\n            vesting = _getVestingAmount(amount, _bonusesVestingPermilleContract, 1_000);\r\n        }\r\n    }\r\n    \r\n    \r\n    /**\r\n     * @dev Returns vesting amount for rewards of `amount`.\r\n     */\r\n    function _getVestingAmountForRewards(uint256 amount)\r\n        internal\r\n        view\r\n        returns (uint256 vesting)\r\n    {\r\n        if (amount \u003e 0) {\r\n            vesting = _getVestingAmount(amount, _rewardsVestingPermilleContract, 1_000);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns vesting amount via the `permilleContract`.\r\n     */\r\n    function _getVestingAmount(uint256 amount, IPermille permilleContract, uint16 defaultPermille)\r\n        private\r\n        view\r\n        returns (uint256 vesting)\r\n    {\r\n        vesting = amount;\r\n\r\n        uint16 permille = defaultPermille;\r\n\r\n        if (permilleContract != IPermille(0)) {\r\n            try permilleContract.permille() returns (uint16 permille_) {\r\n                permille = permille_;\r\n            }\r\n\r\n            catch {\r\n                //\r\n            }\r\n        }\r\n        \r\n        if (permille == 0) {\r\n            vesting = 0;\r\n        }\r\n\r\n        else if (permille \u003c 1_000) {\r\n            vesting = vesting.mul(permille).div(1_000);\r\n        }\r\n    }\r\n}\r\n"},"LibAuthPause.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\nimport \"LibBaseAuth.sol\";\r\n\r\n\r\n/**\r\n * @dev Auth pause.\r\n */\r\ncontract AuthPause is BaseAuth {\r\n    using Roles for Roles.Role;\r\n\r\n    bool private _paused = false;\r\n\r\n    event PausedON();\r\n    event PausedOFF();\r\n\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier onlyNotPaused() {\r\n        require(!_paused, \"Paused\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return Returns true if the contract is paused, false otherwise.\r\n     */\r\n    function isPaused()\r\n        public\r\n        view\r\n        returns (bool)\r\n    {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Sets paused state.\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function setPaused(bool value)\r\n        external\r\n        onlyAgent\r\n    {\r\n        _paused = value;\r\n\r\n        if (_paused) {\r\n            emit PausedON();\r\n        } else {\r\n            emit PausedOFF();\r\n        }\r\n    }\r\n}\r\n"},"LibBaseAuth.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\nimport \"LibRoles.sol\";\r\nimport \"LibIERC20.sol\";\r\n\r\n\r\n/**\r\n * @dev Base auth.\r\n */\r\ncontract BaseAuth {\r\n    using Roles for Roles.Role;\r\n\r\n    Roles.Role private _agents;\r\n\r\n    event AgentAdded(address indexed account);\r\n    event AgentRemoved(address indexed account);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor ()\r\n    {\r\n        _agents.add(msg.sender);\r\n        emit AgentAdded(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by account which is not an agent.\r\n     */\r\n    modifier onlyAgent() {\r\n        require(isAgent(msg.sender), \"AgentRole: caller does not have the Agent role\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Rescue compatible ERC20 Token\r\n     *\r\n     * Can only be called by an agent.\r\n     */\r\n    function rescueToken(\r\n        address tokenAddr,\r\n        address recipient,\r\n        uint256 amount\r\n    )\r\n        external\r\n        onlyAgent\r\n    {\r\n        IERC20 _token = IERC20(tokenAddr);\r\n        require(recipient != address(0), \"Rescue: recipient is the zero address\");\r\n        uint256 balance = _token.balanceOf(address(this));\r\n\r\n        require(balance \u003e= amount, \"Rescue: amount exceeds balance\");\r\n        _token.transfer(recipient, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Withdraw Ether\r\n     *\r\n     * Can only be called by an agent.\r\n     */\r\n    function withdrawEther(\r\n        address payable recipient,\r\n        uint256 amount\r\n    )\r\n        external\r\n        onlyAgent\r\n    {\r\n        require(recipient != address(0), \"Withdraw: recipient is the zero address\");\r\n        uint256 balance = address(this).balance;\r\n        require(balance \u003e= amount, \"Withdraw: amount exceeds balance\");\r\n        recipient.transfer(amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the `account` has the Agent role.\r\n     */\r\n    function isAgent(address account)\r\n        public\r\n        view\r\n        returns (bool)\r\n    {\r\n        return _agents.has(account);\r\n    }\r\n\r\n    /**\r\n     * @dev Give an `account` access to the Agent role.\r\n     *\r\n     * Can only be called by an agent.\r\n     */\r\n    function addAgent(address account)\r\n        public\r\n        onlyAgent\r\n    {\r\n        _agents.add(account);\r\n        emit AgentAdded(account);\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an `account` access from the Agent role.\r\n     *\r\n     * Can only be called by an agent.\r\n     */\r\n    function removeAgent(address account)\r\n        public\r\n        onlyAgent\r\n    {\r\n        _agents.remove(account);\r\n        emit AgentRemoved(account);\r\n    }\r\n}\r\n\r\n"},"LibIERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    function name() external view returns (string memory);\r\n    function symbol() external view returns (string memory);\r\n    function decimals() external view returns (uint8);\r\n    function totalSupply() external view returns (uint256);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n"},"LibIPermille.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n\r\n/**\r\n * @dev Interface of a permille contract.\r\n */\r\ninterface IPermille {\r\n    function permille() external view returns (uint16);\r\n}\r\n"},"LibIVesting.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n\r\n/**\r\n * @dev Interface of an vesting contract.\r\n */\r\ninterface IVesting {\r\n    function vestingOf(address account) external view returns (uint256);\r\n}\r\n"},"LibIVokenTB.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n\r\n/**\r\n * @title Interface of VokenTB.\r\n */\r\ninterface IVokenTB {\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    \r\n    function cap() external view returns (uint256);\r\n    function totalSupply() external view returns (uint256);\r\n    \r\n    function mint(address account, uint256 amount) external returns (bool);\r\n    function mintWithVesting(address account, uint256 amount, address vestingContract) external returns (bool);\r\n\r\n    function referrer(address account) external view returns (address payable);\r\n    function address2voken(address account) external view returns (uint160);\r\n    function voken2address(uint160 voken) external view returns (address payable);\r\n}\r\n"},"LibRoles.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n\r\n/**\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role\r\n    {\r\n        mapping (address =\u003e bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(\r\n        Role storage role,\r\n        address account\r\n    )\r\n        internal\r\n    {\r\n        require(!has(role, account), \"Roles: account already has role\");\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(\r\n        Role storage role,\r\n        address account\r\n    )\r\n        internal\r\n    {\r\n        require(has(role, account), \"Roles: account does not have role\");\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     *\r\n     * @return bool\r\n     */\r\n    function has(\r\n        Role storage role,\r\n        address account\r\n    )\r\n        internal\r\n        view\r\n        returns (bool)\r\n    {\r\n        require(account != address(0), \"Roles: account is the zero address\");\r\n        return role.bearer[account];\r\n    }\r\n}\r\n"},"LibSafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity =0.7.5;\r\n\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMath` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(\r\n        uint256 a,\r\n        uint256 b\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(\r\n        uint256 a,\r\n        uint256 b\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(\r\n        uint256 a,\r\n        uint256 b\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(\r\n        uint256 a,\r\n        uint256 b\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(\r\n        uint256 a,\r\n        uint256 b\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}"}}