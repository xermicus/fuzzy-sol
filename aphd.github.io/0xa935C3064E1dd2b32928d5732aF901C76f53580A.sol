{"ERC20.sol":{"content":"pragma solidity 0.6.5;\n\nimport \"./SafeMath.sol\";\n\nabstract contract ERC20 {\n    using SafeMath for uint256;\n\n    uint256 internal _totalSupply;\n    mapping(address =\u003e uint256) internal _balances;\n    mapping(address =\u003e mapping(address =\u003e uint256)) internal _allowances;\n\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n    event Approval(\n        address indexed owner,\n        address indexed spender,\n        uint256 amount\n    );\n\n    /*\n   * Internal Functions for ERC20 standard logics\n   */\n\n    function _transfer(address from, address to, uint256 amount)\n        internal\n        returns (bool success)\n    {\n        _balances[from] = _balances[from].sub(\n            amount,\n            \"ERC20/transfer : cannot transfer more than token owner balance\"\n        );\n        _balances[to] = _balances[to].add(amount);\n        emit Transfer(from, to, amount);\n        success = true;\n    }\n\n    function _approve(address owner, address spender, uint256 amount)\n        internal\n        returns (bool success)\n    {\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n        success = true;\n    }\n\n    function _mint(address recipient, uint256 amount)\n        internal\n        returns (bool success)\n    {\n        _totalSupply = _totalSupply.add(amount);\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(address(0), recipient, amount);\n        success = true;\n    }\n\n    function _burn(address burned, uint256 amount)\n        internal\n        returns (bool success)\n    {\n        _balances[burned] = _balances[burned].sub(\n            amount,\n            \"ERC20Burnable/burn : Cannot burn more than user\u0027s balance\"\n        );\n        _totalSupply = _totalSupply.sub(\n            amount,\n            \"ERC20Burnable/burn : Cannot burn more than totalSupply\"\n        );\n        emit Transfer(burned, address(0), amount);\n        success = true;\n    }\n\n    /*\n   * public view functions to view common data\n   */\n\n    function totalSupply() external view returns (uint256 total) {\n        total = _totalSupply;\n    }\n    function balanceOf(address owner) external view returns (uint256 balance) {\n        balance = _balances[owner];\n    }\n\n    function allowance(address owner, address spender)\n        external\n        view\n        returns (uint256 remaining)\n    {\n        remaining = _allowances[owner][spender];\n    }\n\n    /*\n   * External view Function Interface to implement on final contract\n   */\n    function name() virtual external view returns (string memory tokenName);\n    function symbol() virtual external view returns (string memory tokenSymbol);\n    function decimals() virtual external view returns (uint8 tokenDecimals);\n\n    /*\n   * External Function Interface to implement on final contract\n   */\n    function transfer(address to, uint256 amount)\n        virtual\n        external\n        returns (bool success);\n    function transferFrom(address from, address to, uint256 amount)\n        virtual\n        external\n        returns (bool success);\n    function approve(address spender, uint256 amount)\n        virtual\n        external\n        returns (bool success);\n}\n"},"ERC20Burnable.sol":{"content":"pragma solidity 0.6.5;\n\nimport \"./ERC20.sol\";\nimport \"./Pausable.sol\";\n\nabstract contract ERC20Burnable is ERC20, Pausable {\n    event Burn(address indexed burned, uint256 amount);\n\n    function burn(uint256 amount)\n        external\n        whenNotPaused\n        returns (bool success)\n    {\n        success = _burn(msg.sender, amount);\n        emit Burn(msg.sender, amount);\n        success = true;\n    }\n\n    function burnFrom(address burned, uint256 amount)\n        external\n        whenNotPaused\n        returns (bool success)\n    {\n        _burn(burned, amount);\n        emit Burn(burned, amount);\n        success = _approve(\n            burned,\n            msg.sender,\n            _allowances[burned][msg.sender].sub(\n                amount,\n                \"ERC20Burnable/burnFrom : Cannot burn more than allowance\"\n            )\n        );\n    }\n}\n"},"ERC20Lockable.sol":{"content":"pragma solidity 0.6.5;\n\nimport \"./ERC20.sol\";\nimport \"./Ownable.sol\";\n\nabstract contract ERC20Lockable is ERC20, Ownable {\n    struct LockInfo {\n        uint256 amount;\n        uint256 due;\n    }\n\n    mapping(address =\u003e LockInfo[]) internal _locks;\n    mapping(address =\u003e uint256) internal _totalLocked;\n\n    event Lock(address indexed from, uint256 amount, uint256 due);\n    event Unlock(address indexed from, uint256 amount);\n\n    modifier checkLock(address from, uint256 amount) {\n        require(_balances[from] \u003e= _totalLocked[from].add(amount), \"ERC20Lockable/Cannot send more than unlocked amount\");\n        _;\n    }\n\n    function _lock(address from, uint256 amount, uint256 due)\n        internal\n        returns (bool success)\n    {\n        require(due \u003e now, \"ERC20Lockable/lock : Cannot set due to past\");\n        require(\n            _balances[from] \u003e= amount.add(_totalLocked[from]),\n            \"ERC20Lockable/lock : locked total should be smaller than balance\"\n        );\n        _totalLocked[from] = _totalLocked[from].add(amount);\n        _locks[from].push(LockInfo(amount, due));\n        emit Lock(from, amount, due);\n        success = true;\n    }\n\n    function _unlock(address from, uint256 index) internal returns (bool success) {\n        LockInfo storage lock = _locks[from][index];\n        _totalLocked[from] = _totalLocked[from].sub(lock.amount);\n        emit Unlock(from, lock.amount);\n        _locks[from][index] = _locks[from][_locks[from].length - 1];\n        _locks[from].pop();\n        success = true;\n    }\n\n    function unlock(address from) external returns (bool success) {\n        for(uint256 i = 0; i \u003c _locks[from].length; i++){\n            if(_locks[from][i].due \u003c now){\n                _unlock(from, i);\n            }\n        }\n        success = true;\n    }\n\n    function releaseLock(address from)\n        external\n        onlyOwner\n        returns (bool success)\n    {\n        for(uint256 i = 0; i \u003c _locks[from].length; i++){\n            _unlock(from, i);\n        }\n        success = true;\n    }\n\n    function transferWithLockUp(address recipient, uint256 amount, uint256 due)\n        external\n        returns (bool success)\n    {\n        require(\n            recipient != address(0),\n            \"ERC20Lockable/transferWithLockUp : Cannot send to zero address\"\n        );\n        _transfer(msg.sender, recipient, amount);\n        _lock(recipient, amount, due);\n        success = true;\n    }\n\n    function lockInfo(address locked, uint256 index)\n        external\n        view\n        returns (uint256 amount, uint256 due)\n    {\n        LockInfo memory lock = _locks[locked][index];\n        amount = lock.amount;\n        due = lock.due;\n    }\n\n    function totalLocked(address locked) external view returns(uint256 amount, uint256 length){\n        amount = _totalLocked[locked];\n        length = _locks[locked].length;\n    }\n}\n"},"ERC20Mintable.sol":{"content":"pragma solidity 0.6.5;\n\nimport \"./ERC20.sol\";\nimport \"./Pausable.sol\";\n\nabstract contract ERC20Mintable is ERC20, Pausable {\n    event Mint(address indexed receiver, uint256 amount);\n    event MintFinished();\n    uint256 internal _cap;\n    bool internal _mintingFinished;\n    ///@notice mint token\n    ///@dev only owner can call this function\n    function mint(address receiver, uint256 amount)\n        external\n        onlyOwner\n        whenNotPaused\n        returns (bool success)\n    {\n        require(\n            receiver != address(0),\n            \"ERC20Mintable/mint : Should not mint to zero address\"\n        );\n        require(\n            _totalSupply.add(amount) \u003c= _cap,\n            \"ERC20Mintable/mint : Cannot mint over cap\"\n        );\n        require(\n            !_mintingFinished,\n            \"ERC20Mintable/mint : Cannot mint after finished\"\n        );\n        _mint(receiver, amount);\n        emit Mint(receiver, amount);\n        success = true;\n    }\n\n    ///@notice finish minting, cannot mint after calling this function\n    ///@dev only owner can call this function\n    function finishMint()\n        external\n        onlyOwner\n        returns (bool success)\n    {\n        require(\n            !_mintingFinished,\n            \"ERC20Mintable/finishMinting : Already finished\"\n        );\n        _mintingFinished = true;\n        emit MintFinished();\n        return true;\n    }\n\n    function cap()\n        external\n        view\n        returns (uint256)\n    {\n        return _cap;\n    }\n\n    function isFinished() external view returns(bool finished) {\n        finished = _mintingFinished;\n    }\n}\n"},"Freezable.sol":{"content":"pragma solidity 0.6.5;\n\nimport \"./Ownable.sol\";\n\ncontract Freezable is Ownable {\n    mapping(address =\u003e bool) private _frozen;\n\n    event Freeze(address indexed target);\n    event Unfreeze(address indexed target);\n\n    modifier whenNotFrozen(address target) {\n        require(!_frozen[target], \"Freezable : target is frozen\");\n        _;\n    }\n\n    function freeze(address target) external onlyOwner returns (bool success) {\n        _frozen[target] = true;\n        emit Freeze(target);\n        success = true;\n    }\n\n    function unFreeze(address target)\n        external\n        onlyOwner\n        returns (bool success)\n    {\n        _frozen[target] = false;\n        emit Unfreeze(target);\n        success = true;\n    }\n\n    function isFrozen(address target)\n        external\n        view\n        returns (bool frozen)\n    {\n        return _frozen[target];\n    }\n}\n"},"Ownable.sol":{"content":"pragma solidity 0.6.5;\n\ncontract Ownable {\n    address internal _owner;\n\n    event OwnershipTransferred(\n        address indexed currentOwner,\n        address indexed newOwner\n    );\n\n    constructor() internal {\n        _owner = msg.sender;\n        emit OwnershipTransferred(address(0), msg.sender);\n    }\n\n    modifier onlyOwner() {\n        require(\n            msg.sender == _owner,\n            \"Ownable : Function called by unauthorized user.\"\n        );\n        _;\n    }\n\n    function owner() external view returns (address ownerAddress) {\n        ownerAddress = _owner;\n    }\n\n    function transferOwnership(address newOwner)\n        public\n        onlyOwner\n        returns (bool success)\n    {\n        require(newOwner != address(0), \"Ownable/transferOwnership : cannot transfer ownership to zero address\");\n        success = _transferOwnership(newOwner);\n    }\n\n    function renounceOwnership() external onlyOwner returns (bool success) {\n        success = _transferOwnership(address(0));\n    }\n\n    function _transferOwnership(address newOwner) internal returns (bool success) {\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n        success = true;\n    }\n}\n"},"Pausable.sol":{"content":"pragma solidity 0.6.5;\n\nimport \"./Ownable.sol\";\n\ncontract Pausable is Ownable {\n    bool internal _paused;\n\n    event Paused();\n    event Unpaused();\n\n    modifier whenPaused() {\n        require(_paused, \"Paused : This function can only be called when paused\");\n        _;\n    }\n\n    modifier whenNotPaused() {\n        require(!_paused, \"Paused : This function can only be called when not paused\");\n        _;\n    }\n\n    function pause() external onlyOwner whenNotPaused returns (bool success) {\n        _paused = true;\n        emit Paused();\n        success = true;\n    }\n\n    function unPause() external onlyOwner whenPaused returns (bool success) {\n        _paused = false;\n        emit Unpaused();\n        success = true;\n    }\n\n    function paused() external view returns (bool) {\n        return _paused;\n    }\n}\n"},"SafeMath.sol":{"content":"pragma solidity 0.6.5;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     *\n     * _Available since v2.4.0._\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage)\n        internal\n        pure\n        returns (uint256)\n    {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * _Available since v2.4.0._\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage)\n        internal\n        pure\n        returns (uint256)\n    {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     *\n     * _Available since v2.4.0._\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage)\n        internal\n        pure\n        returns (uint256)\n    {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n"},"seed..sol":{"content":"pragma solidity 0.6.5;\n\nimport \"./ERC20Lockable.sol\";\nimport \"./ERC20Burnable.sol\";\nimport \"./ERC20Mintable.sol\";\nimport \"./Pausable.sol\";\nimport \"./Freezable.sol\";\n\ncontract SEED is\n    ERC20Lockable,\n    ERC20Burnable,\n    ERC20Mintable,\n    Freezable\n{\n    string constant private _name = \"SEED\";\n    string constant private _symbol = \"SEED\";\n    uint8 constant private _decimals = 8;\n    uint256 constant private _initial_supply = 2_000_000_000;\n\n    constructor() public Ownable() {\n        _cap = 2_000_000_000 * (10**uint256(_decimals));\n        _mint(msg.sender, _initial_supply * (10**uint256(_decimals)));\n    }\n\n    function transfer(address to, uint256 amount)\n        override\n        external\n        whenNotFrozen(msg.sender)\n        whenNotPaused\n        checkLock(msg.sender, amount)\n        returns (bool success)\n    {\n        require(\n            to != address(0),\n            \"SEED/transfer : Should not send to zero address\"\n        );\n        _transfer(msg.sender, to, amount);\n        success = true;\n    }\n\n    function transferFrom(address from, address to, uint256 amount)\n        override\n        external\n        whenNotFrozen(from)\n        whenNotPaused\n        checkLock(from, amount)\n        returns (bool success)\n    {\n        require(\n            to != address(0),\n            \"SEED/transferFrom : Should not send to zero address\"\n        );\n        _transfer(from, to, amount);\n        _approve(\n            from,\n            msg.sender,\n            _allowances[from][msg.sender].sub(\n                amount,\n                \"SEED/transferFrom : Cannot send more than allowance\"\n            )\n        );\n        success = true;\n    }\n\n    function approve(address spender, uint256 amount)\n        override\n        external\n        returns (bool success)\n    {\n        require(\n            spender != address(0),\n            \"SEED/approve : Should not approve zero address\"\n        );\n        _approve(msg.sender, spender, amount);\n        success = true;\n    }\n\n    function name() override external view returns (string memory tokenName) {\n        tokenName = _name;\n    }\n\n    function symbol() override external view returns (string memory tokenSymbol) {\n        tokenSymbol = _symbol;\n    }\n\n    function decimals() override external view returns (uint8 tokenDecimals) {\n        tokenDecimals = _decimals;\n    }\n}"}}