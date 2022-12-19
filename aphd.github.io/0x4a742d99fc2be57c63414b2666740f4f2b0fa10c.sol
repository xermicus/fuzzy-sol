{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\nimport \"./IERC20Metadata.sol\";\nimport \"./Context.sol\";\nimport \"./SafeMath.sol\";\nimport \"./Ownable.sol\";\n\ncontract ERC20 is Context, IERC20, IERC20Metadata, Ownable {\n    using SafeMath for uint256;\n\n    mapping (address =\u003e uint256) _balances;\n\n    mapping (address =\u003e mapping (address =\u003e uint256)) _allowances;\n\n    uint256 private _totalSupply;\n    uint8 private _decimals;\n    string private _name;\n    string private _symbol;\n\n    constructor (string memory name_, string memory symbol_){\n        _name = name_;\n        _symbol = symbol_;\n        _decimals = 18;\n        _totalSupply = 10000000000000000000000000;\n        \n        _balances[_msgSender()] = _totalSupply;\n        emit Transfer(address(0), _msgSender(), _totalSupply);\n    }\n\n\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n\n    function decimals() public view virtual override returns (uint8) {\n        return 18;\n    }\n\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\n        require(currentAllowance \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\n        _approve(sender, _msgSender(), currentAllowance.sub(amount));\n\n        return true;\n    }\n\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\n        return true;\n    }\n\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\n        _approve(_msgSender(), spender, currentAllowance - subtractedValue);\n\n        return true;\n    }\n\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        uint256 senderBalance = _balances[sender];\n        require(senderBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\n        _balances[sender] = senderBalance.sub(amount);\n        _balances[recipient] = _balances[recipient].add(amount);\n\n        emit Transfer(sender, recipient, amount);\n    }\n\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n\ninterface IERC20 {\n    function totalSupply() external view returns (uint256);\n\n    \n    function balanceOf(address account) external view returns (uint256);\n\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\n\n\ninterface IERC20Metadata is IERC20 {\n    function name() external view returns (string memory);\n\n    function symbol() external view returns (string memory);\n\n    function decimals() external view returns (uint8);\n}"},"Migrations.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.4.22 \u003c0.9.0;\n\ncontract Migrations {\n  address public owner = msg.sender;\n  uint public last_completed_migration;\n\n  modifier restricted() {\n    require(\n      msg.sender == owner,\n      \"This function is restricted to the contract\u0027s owner\"\n    );\n    _;\n  }\n\n  function setCompleted(uint completed) public restricted {\n    last_completed_migration = completed;\n  }\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    constructor () {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n\nlibrary SafeMath {\n\n  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\n    if (a == 0) {\n      return 0;\n    }\n    c = a * b;\n    assert(c / a == b);\n    return c;\n  }\n\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n    // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\n    // uint256 c = a / b;\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n    return a / b;\n  }\n\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n    assert(b \u003c= a);\n    return a - b;\n  }\n\n  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\n    c = a + b;\n    assert(c \u003e= a);\n    return c;\n  }\n}"},"TokenLock.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./ERC20.sol\";\nimport \"./SafeMath.sol\";\nimport \"./Ownable.sol\";\n\ncontract TokenLock is Ownable {\n    using SafeMath for uint256;\n    using SafeMath for uint16;\n\n    struct TokenGate {\n        uint256 startTime;\n        uint256 amount;\n        uint16 Duration;\n        uint16 daysClaimed;\n        uint256 totalClaimed;\n        address recipient;\n    }\n\n    event GateAdded(address indexed recipient);\n    event GateTokensClaimed(address indexed recipient, uint256 amountClaimed);\n    event GateRevoked(address recipient, uint256 amountVested, uint256 amountNotVested);\n\n    ERC20 public token;\n    \n    mapping (address =\u003e TokenGate) private ReleaseAddresses;\n\n    constructor(ERC20 _token) {\n        token = _token;\n    }\n    \n    function addTokenGate(\n        address _recipient,\n        uint256 _amount,\n        uint16 _DurationInDays,\n        uint16 _vestingCliffInDays    \n    ) \n        external\n        onlyOwner\n    {\n        require(ReleaseAddresses[_recipient].amount == 0, \"Gate already exists, must revoke first.\");\n        require(_vestingCliffInDays \u003e= 0, \"Cliff not less than 0 days\");\n        require(_DurationInDays \u003e= 0, \"Duration not less than 0 days\");\n        \n        uint256 amountVestedPerDay = _amount.div(_DurationInDays);\n        require(amountVestedPerDay \u003e= 0, \"amountVestedPerDay \u003e 0\");\n\n        // Transfer the gated tokens under the control of the vesting contract\n        require(token.transferFrom(owner(), address(this), _amount));\n\n        TokenGate memory releaseaddress = TokenGate({\n            startTime: currentTime() + _vestingCliffInDays * 1 days,\n            amount: _amount,\n            Duration: _DurationInDays,\n            daysClaimed: 0,\n            totalClaimed: 0,\n            recipient: _recipient\n        });\n        ReleaseAddresses[_recipient] = releaseaddress;\n        emit GateAdded(_recipient);\n    }\n\n    function claimVestedTokens() external {\n        uint16 daysVested;\n        uint256 amountVested;\n        (daysVested, amountVested) = calculateTokenClaim(msg.sender);\n        require(amountVested \u003e 0, \"Vested must be greater than 0\");\n\n        TokenGate storage tokenRelease = ReleaseAddresses[msg.sender];\n        tokenRelease.daysClaimed = uint16(tokenRelease.daysClaimed.add(daysVested));\n        tokenRelease.totalClaimed = uint256(tokenRelease.totalClaimed.add(amountVested));\n        \n        require(token.transfer(tokenRelease.recipient, amountVested), \"no tokens\");\n        emit GateTokensClaimed(tokenRelease.recipient, amountVested);\n    }\n\n    function revokeTokenGate(address _recipient) \n        external \n        onlyOwner\n    {\n        TokenGate storage tokenRelease = ReleaseAddresses[_recipient];\n        uint16 daysVested;\n        uint256 amountVested;\n        (daysVested, amountVested) = calculateTokenClaim(_recipient);\n\n        uint256 amountNotVested = (tokenRelease.amount.sub(tokenRelease.totalClaimed)).sub(amountVested);\n\n        require(token.transfer(owner(), amountNotVested));\n        require(token.transfer(_recipient, amountVested));\n\n        tokenRelease.startTime = 0;\n        tokenRelease.amount = 0;\n        tokenRelease.Duration = 0;\n        tokenRelease.daysClaimed = 0;\n        tokenRelease.totalClaimed = 0;\n        tokenRelease.recipient = address(0);\n\n        emit GateRevoked(_recipient, amountVested, amountNotVested);\n    }\n\n    function getGateStartTime(address _recipient) public view returns(uint256) {\n        TokenGate storage tokenRelease = ReleaseAddresses[_recipient];\n        return tokenRelease.startTime;\n    }\n\n    function getGateAmount(address _recipient) public view returns(uint256) {\n        TokenGate storage tokenRelease = ReleaseAddresses[_recipient];\n        return tokenRelease.amount;\n    }\n\n    function calculateTokenClaim(address _recipient) private view returns (uint16, uint256) {\n        TokenGate storage tokenRelease = ReleaseAddresses[_recipient];\n\n        require(tokenRelease.totalClaimed \u003c tokenRelease.amount, \"Release fully claimed\");\n\n        if (currentTime() \u003c tokenRelease.startTime) {\n            return (0, 0);\n        }\n\n        uint elapsedDays = currentTime().sub(tokenRelease.startTime - 1 days).div(1 days);\n\n        if (elapsedDays \u003e= tokenRelease.Duration) {\n            uint256 remainingTokens = tokenRelease.amount.sub(tokenRelease.totalClaimed);\n            return (tokenRelease.Duration, remainingTokens);\n        } else {\n            uint16 daysVested = uint16(elapsedDays.sub(tokenRelease.daysClaimed));\n            uint256 amountVestedPerDay = tokenRelease.amount.div(uint256(tokenRelease.Duration));\n            uint256 amountVested = uint256(daysVested.mul(amountVestedPerDay));\n            return (daysVested, amountVested);\n        }\n    }\n\n    function currentTime() private view returns(uint256) {\n        return block.timestamp;\n    }\n}"}}