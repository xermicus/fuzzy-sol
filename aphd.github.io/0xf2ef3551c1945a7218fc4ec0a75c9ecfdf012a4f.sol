{"C4g3.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.6;\npragma experimental ABIEncoderV2;\n\nimport \"./SafeMath.sol\";\n\ncontract C4g3 {\n    /// @notice EIP-20 token name for this token\n    string public constant name = \"CAGE\";\n\n    /// @notice EIP-20 token symbol for this token\n    string public constant symbol = \"C4G3\";\n\n    /// @notice EIP-20 token decimals for this token\n    uint8 public constant decimals = 18;\n\n    /// @notice Total number of tokens in circulation\n    uint public totalSupply = 100_000_000e18; // 100 million C4G3\n\n    /// @notice Official record of token balances for each account\n    mapping (address =\u003e uint96) internal balances;\n\n    /// @notice The EIP-712 typehash for the contract\u0027s domain\n    bytes32 public constant DOMAIN_TYPEHASH = keccak256(\"EIP712Domain(string name,uint256 chainId,address verifyingContract)\");\n\n       /// @notice The EIP-712 typehash for the permit struct used by the contract\n    bytes32 public constant PERMIT_TYPEHASH = keccak256(\"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\");\n\n    /// @notice A record of states for signing / validating signatures\n    mapping (address =\u003e uint) public nonces;\n\n    /// @notice The standard EIP-20 transfer event\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    /// @notice The standard EIP-20 approval event\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\n\n    /// @notice Allowance amounts on behalf of others\n    mapping (address =\u003e mapping (address =\u003e uint96)) internal allowances;\n\n\n\n    /**\n     * @notice Construct a new C4g3 token\n     * @param account The initial account to grant all the tokens\n     */\n    constructor(address account) public {\n        balances[account] = uint96(totalSupply);\n        emit Transfer(address(0), account, totalSupply);\n    }\n\n\n    /**\n     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`\n     * @param account The address of the account holding the funds\n     * @param spender The address of the account spending the funds\n     * @return The number of tokens approved\n     */\n    function allowance(address account, address spender) external view returns (uint) {\n        return allowances[account][spender];\n    }\n\n    /**\n     * @notice Approve `spender` to transfer up to `amount` from `src`\n     * @dev This will overwrite the approval amount for `spender`\n     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)\n     * @param spender The address of the account which may transfer tokens\n     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)\n     * @return Whether or not the approval succeeded\n     */\n    function approve(address spender, uint rawAmount) external returns (bool) {\n        uint96 amount;\n        if (rawAmount == type(uint).max) {\n            amount = type(uint96).max;\n        }  else {\n            amount = safe96(rawAmount, \"C4g3::approve: amount exceeds 96 bits\");\n        }\n\n        allowances[msg.sender][spender] = amount;\n\n        emit Approval(msg.sender, spender, amount);\n        return true;\n    }\n\n    /**\n     * @notice Triggers an approval from owner to spends\n     * @param owner The address to approve from\n     * @param spender The address to be approved\n     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)\n     * @param deadline The time at which to expire the signature\n     * @param v The recovery byte of the signature\n     * @param r Half of the ECDSA signature pair\n     * @param s Half of the ECDSA signature pair\n     */\n    function permit(address owner, address spender, uint rawAmount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {\n        uint96 amount;\n        if (rawAmount == type(uint).max) {\n            amount = type(uint96).max;\n        } else {\n            amount = safe96(rawAmount, \"C4g3::permit: amount exceeds 96 bits\");\n        }\n\n        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));\n        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline));\n        bytes32 digest = keccak256(abi.encodePacked(\"\\x19\\x01\", domainSeparator, structHash));\n        address signatory = ecrecover(digest, v, r, s);\n        require(signatory != address(0), \"C4g3::permit: invalid signature\");\n        require(signatory == owner, \"C4g3::permit: unauthorized\");\n        require(block.timestamp \u003c= deadline, \"C4g3::permit: signature expired\");\n\n        allowances[owner][spender] = amount;\n\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @notice Get the number of tokens held by the `account`\n     * @param account The address of the account to get the balance of\n     * @return The number of tokens held\n     */\n    function balanceOf(address account) external view returns (uint) {\n        return balances[account];\n    }\n\n    /**\n     * @notice Transfer `amount` tokens from `msg.sender` to `dst`\n     * @param dst The address of the destination account\n     * @param rawAmount The number of tokens to transfer\n     * @return Whether or not the transfer succeeded\n     */\n    function transfer(address dst, uint rawAmount) external returns (bool) {\n        uint96 amount = safe96(rawAmount, \"C4g3::transfer: amount exceeds 96 bits\");\n        _transferTokens(msg.sender, dst, amount);\n        return true;\n    }\n\n    /**\n     * @notice Transfer `amount` tokens from `src` to `dst`\n     * @param src The address of the source account\n     * @param dst The address of the destination account\n     * @param rawAmount The number of tokens to transfer\n     * @return Whether or not the transfer succeeded\n     */\n    function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {\n        address spender = msg.sender;\n        uint96 spenderAllowance = allowances[src][spender];\n        uint96 amount = safe96(rawAmount, \"C4g3::approve: amount exceeds 96 bits\");\n\n        if (spender != src \u0026\u0026 spenderAllowance != type(uint96).max) {\n            uint96 newAllowance = sub96(spenderAllowance, amount, \"C4g3::transferFrom: transfer amount exceeds spender allowance\");\n            allowances[src][spender] = newAllowance;\n\n            emit Approval(src, spender, newAllowance);\n        }\n\n        _transferTokens(src, dst, amount);\n        return true;\n    }\n\n\n    function _transferTokens(address src, address dst, uint96 amount) internal {\n        require(src != address(0), \"C4g3::_transferTokens: cannot transfer from the zero address\");\n        require(dst != address(0), \"C4g3::_transferTokens: cannot transfer to the zero address\");\n\n        balances[src] = sub96(balances[src], amount, \"C4g3::_transferTokens: transfer amount exceeds balance\");\n        balances[dst] = add96(balances[dst], amount, \"C4g3::_transferTokens: transfer amount overflows\");\n        emit Transfer(src, dst, amount);\n\n    }\n\n    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {\n        require(n \u003c 2**32, errorMessage);\n        return uint32(n);\n    }\n\n    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {\n        require(n \u003c 2**96, errorMessage);\n        return uint96(n);\n    }\n\n    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {\n        uint96 c = a + b;\n        require(c \u003e= a, errorMessage);\n        return c;\n    }\n\n    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {\n        require(b \u003c= a, errorMessage);\n        return a - b;\n    }\n\n    function getChainId() internal view returns (uint) {\n        uint256 chainId;\n        assembly { chainId := chainid() }\n        return chainId;\n    }\n}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.6;\n\n// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol\n// Subject to the MIT license.\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, errorMessage);\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot underflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction underflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot underflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, errorMessage);\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers.\n     * Reverts on division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers.\n     * Reverts with custom message on division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}"}}