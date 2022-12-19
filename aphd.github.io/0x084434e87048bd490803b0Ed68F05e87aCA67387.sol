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
    "@openzeppelin/contracts/cryptography/MerkleProof.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev These functions deal with verification of Merkle trees (hash trees),\n */\nlibrary MerkleProof {\n    /**\n     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree\n     * defined by `root`. For this, a `proof` must be provided, containing\n     * sibling hashes on the branch from the leaf to the root of the tree. Each\n     * pair of leaves and each pair of pre-images are assumed to be sorted.\n     */\n    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {\n        bytes32 computedHash = leaf;\n\n        for (uint256 i = 0; i < proof.length; i++) {\n            bytes32 proofElement = proof[i];\n\n            if (computedHash <= proofElement) {\n                // Hash(current computed hash + current element of the proof)\n                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));\n            } else {\n                // Hash(current element of the proof + current computed hash)\n                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));\n            }\n        }\n\n        // Check if the computed hash (root) is equal to the provided root\n        return computedHash == root;\n    }\n}\n"
    },
    "@openzeppelin/contracts/math/SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it's recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        uint256 c = a + b;\n        if (c < a) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b > a) return (false, 0);\n        return (true, a - b);\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) return (true, 0);\n        uint256 c = a * b;\n        if (c / a != b) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a / b);\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a % b);\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b <= a, \"SafeMath: subtraction overflow\");\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) return 0;\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryDiv}.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a % b;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "contracts/MerkleDistributor.sol": {
      "content": "//SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport \"@openzeppelin/contracts/cryptography/MerkleProof.sol\";\nimport \"@openzeppelin/contracts/math/SafeMath.sol\";\nimport \"./interfaces/IMerkleDistributor.sol\";\n\ncontract MerkleDistributor is IMerkleDistributor {\n  using SafeMath for uint256;\n  address public immutable override token;\n  bytes32 public immutable override merkleRoot;\n  // This is a packed array of booleans.\n  mapping(uint256 => uint256) private claimedBitMap;\n\n  // Opium Bonus\n  uint256 public constant MAX_BONUS = 0.999e18;\n  uint256 public constant PERCENTAGE_BASE = 1e18;\n\n  uint256 public totalClaims;\n  uint256 public initialPoolSize;\n  uint256 public currentPoolSize;\n  uint256 public bonusSum;\n  uint256 public claimed;\n  uint256 public percentageIndex;\n  uint256 public bonusStart;\n  uint256 public bonusEnd;\n  uint256 public emergencyTimeout;\n  address public emergencyReceiver;\n\n  constructor(\n    address token_, // token to be airdropped\n    bytes32 merkleRoot_, // generated merkle root of airdrop recipients/amounts\n    uint256 _totalClaims, // number of accounts eligible for airdrop\n    uint256 _initialPoolSize, // sum of all airdrop amounts, in wei\n    uint256 _bonusStart, // timestamp at which bonus starts\n    uint256 _bonusEnd, // timestamp after which bonus is max\n    uint256 _emergencyTimeout, // time after which an emergency withdrawal can be made\n    address _emergencyReceiver // receiver of emergency withdrawal, after emergency timeout passes\n  ) {\n    token = token_;\n    merkleRoot = merkleRoot_;\n    // Opium Bonus\n    totalClaims = _totalClaims;\n    initialPoolSize = _initialPoolSize;\n    currentPoolSize = _initialPoolSize;\n    percentageIndex = PERCENTAGE_BASE;\n    bonusStart = _bonusStart;\n    bonusEnd = _bonusEnd;\n    emergencyTimeout = _emergencyTimeout;\n    emergencyReceiver = _emergencyReceiver;\n    require(bonusStart < bonusEnd, \"WRONG_BONUS_TIME\");\n    require(emergencyTimeout > bonusEnd, \"WRONG_EMERGENCY_TIMEOUT\");\n  }\n\n  function isClaimed(uint256 index) public view override returns (bool) {\n    uint256 claimedWordIndex = index / 256;\n    uint256 claimedBitIndex = index % 256;\n    uint256 claimedWord = claimedBitMap[claimedWordIndex];\n    uint256 mask = (1 << claimedBitIndex);\n    return claimedWord & mask == mask;\n  }\n\n  function _setClaimed(uint256 index) private {\n    uint256 claimedWordIndex = index / 256;\n    uint256 claimedBitIndex = index % 256;\n    claimedBitMap[claimedWordIndex] =\n      claimedBitMap[claimedWordIndex] |\n      (1 << claimedBitIndex);\n  }\n\n  function claim(\n    uint256 index,\n    address account,\n    uint256 amount,\n    bytes32[] calldata merkleProof\n  ) external override {\n    require(!isClaimed(index), \"MerkleDistributor: Drop already claimed.\");\n    require(msg.sender == account, \"Only owner can claim\");\n    // Verify the merkle proof.\n    bytes32 node = keccak256(abi.encodePacked(index, account, amount));\n    require(\n      MerkleProof.verify(merkleProof, merkleRoot, node),\n      \"MerkleDistributor: Invalid proof.\"\n    );\n    // Mark it claimed and send the token.\n    _setClaimed(index);\n    uint256 adjustedAmount = _applyAdjustment(amount);\n    require(\n      IERC20(token).transfer(account, adjustedAmount),\n      \"MerkleDistributor: Transfer failed.\"\n    );\n    emit Claimed(index, account, adjustedAmount);\n  }\n\n  function getBonus() public view returns (uint256) {\n    // timeRemaining = bonusEnd - now, or 0 if bonus ended\n    uint256 timeRemaining =\n      block.timestamp > bonusEnd ? 0 : bonusEnd.sub(block.timestamp);\n    // bonus = maxBonus * timeRemaining / (bonusEnd - bonusStart)\n    return MAX_BONUS.mul(timeRemaining).div(bonusEnd.sub(bonusStart));\n  }\n\n  function calculateAdjustedAmount(uint256 amount)\n    public\n    view\n    returns (\n      uint256 adjustedAmount,\n      uint256 bonus,\n      uint256 bonusPart\n    )\n  {\n    // If last claims, return full amount + full bonus\n    if (claimed + 1 == totalClaims) {\n      return (amount.add(bonusSum), 0, 0);\n    }\n    // adjustedPercentage = amount / initialPoolSize * percentageIndex\n    uint256 adjustedPercentage =\n      amount.mul(PERCENTAGE_BASE).div(initialPoolSize).mul(percentageIndex).div(\n        PERCENTAGE_BASE\n      );\n    // bonusPart = adjustedPercentage * bonusSum\n    bonusPart = adjustedPercentage.mul(bonusSum).div(PERCENTAGE_BASE);\n    // totalToClaim = amount + bonusPart\n    uint256 totalToClaim = amount.add(bonusPart);\n    // bonus = totalToClaim * getBonus()\n    bonus = totalToClaim.mul(getBonus()).div(PERCENTAGE_BASE);\n    // adjustedAmount = totalToClaim - bonus\n    adjustedAmount = totalToClaim.sub(bonus);\n  }\n\n  function _applyAdjustment(uint256 amount) private returns (uint256) {\n    (uint256 adjustedAmount, uint256 bonus, uint256 bonusPart) =\n      calculateAdjustedAmount(amount);\n    // Increment claim index\n    claimed += 1;\n\n    // If last claims, return full amount, don't update anything\n    if (claimed == totalClaims) {\n      return adjustedAmount;\n    }\n    // newPoolSize = currentPoolSize - amount\n    uint256 newPoolSize = currentPoolSize.sub(amount);\n    // percentageIndex = percentageIndex * currentPoolSize / newPoolSize\n    percentageIndex = percentageIndex\n      .mul(currentPoolSize.mul(PERCENTAGE_BASE).div(newPoolSize))\n      .div(PERCENTAGE_BASE);\n    // currentPoolSize = newPoolSize\n    currentPoolSize = newPoolSize;\n    // bonusSum = bonusSum - bonusPart + bonus\n    bonusSum = bonusSum.sub(bonusPart).add(bonus);\n    return adjustedAmount;\n  }\n\n  function emergencyWithdrawal() public {\n    require(block.timestamp > emergencyTimeout, \"TIMEOUT_NOT_EXPIRED\");\n    IERC20(token).transfer(\n      emergencyReceiver,\n      IERC20(token).balanceOf(address(this))\n    );\n  }\n}\n"
    },
    "contracts/interfaces/IMerkleDistributor.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.7.0;\n\n// Allows anyone to claim a token if they exist in a merkle root.\ninterface IMerkleDistributor {\n  // Returns the address of the token distributed by this contract.\n  function token() external view returns (address);\n\n  // Returns the merkle root of the merkle tree containing account balances available to claim.\n  function merkleRoot() external view returns (bytes32);\n\n  // Returns true if the index has been marked claimed.\n  function isClaimed(uint256 index) external view returns (bool);\n\n  // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.\n  function claim(\n    uint256 index,\n    address account,\n    uint256 amount,\n    bytes32[] calldata merkleProof\n  ) external;\n\n  // This event is triggered whenever a call to #claim succeeds.\n  event Claimed(uint256 index, address account, uint256 amount);\n}\n"
    }
  }
}}