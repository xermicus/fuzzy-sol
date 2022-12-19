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
      "runs": 999999
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "@openzeppelin/contracts/utils/structs/EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Library for managing\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\n * types.\n *\n * Sets have the following properties:\n *\n * - Elements are added, removed, and checked for existence in constant time\n * (O(1)).\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\n *\n * ```\n * contract Example {\n *     // Add the library methods\n *     using EnumerableSet for EnumerableSet.AddressSet;\n *\n *     // Declare a set state variable\n *     EnumerableSet.AddressSet private mySet;\n * }\n * ```\n *\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\n * and `uint256` (`UintSet`) are supported.\n */\nlibrary EnumerableSet {\n    // To implement this library for multiple types with as little code\n    // repetition as possible, we write it in terms of a generic Set type with\n    // bytes32 values.\n    // The Set implementation uses private functions, and user-facing\n    // implementations (such as AddressSet) are just wrappers around the\n    // underlying Set.\n    // This means that we can only create new EnumerableSets for types that fit\n    // in bytes32.\n\n    struct Set {\n        // Storage of set values\n        bytes32[] _values;\n\n        // Position of the value in the `values` array, plus 1 because index 0\n        // means a value is not in the set.\n        mapping (bytes32 => uint256) _indexes;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function _add(Set storage set, bytes32 value) private returns (bool) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            // The value is stored at length-1, but we add 1 to all indexes\n            // and use 0 as a sentinel value\n            set._indexes[value] = set._values.length;\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\n        // We read and store the value's index to prevent multiple reads from the same storage slot\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) { // Equivalent to contains(set, value)\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\n            // the array, and then remove the last element (sometimes called as 'swap and pop').\n            // This modifies the order of the array, as noted in {at}.\n\n            uint256 toDeleteIndex = valueIndex - 1;\n            uint256 lastIndex = set._values.length - 1;\n\n            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs\n            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.\n\n            bytes32 lastvalue = set._values[lastIndex];\n\n            // Move the last value to the index where the value to delete is\n            set._values[toDeleteIndex] = lastvalue;\n            // Update the index for the moved value\n            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based\n\n            // Delete the slot where the moved value was stored\n            set._values.pop();\n\n            // Delete the index for the deleted slot\n            delete set._indexes[value];\n\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\n        require(set._values.length > index, \"EnumerableSet: index out of bounds\");\n        return set._values[index];\n    }\n\n    // Bytes32Set\n\n    struct Bytes32Set {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _add(set._inner, value);\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _remove(set._inner, value);\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\n        return _contains(set._inner, value);\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(Bytes32Set storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\n        return _at(set._inner, index);\n    }\n\n    // AddressSet\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(AddressSet storage set, address value) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(AddressSet storage set, address value) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\n        return address(uint160(uint256(_at(set._inner, index))));\n    }\n\n\n    // UintSet\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n}\n"
    },
    "contracts/PrivateSaleB.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts/utils/structs/EnumerableSet.sol\";\nimport \"./abstract/Ownable.sol\";\nimport \"./libraries/SafeERC20.sol\";\n\n/// @title PrivateSaleB\n/// @dev A token sale contract that accepts only desired USD stable coins as a payment. Blocks any direct ETH deposits.\ncontract PrivateSaleB is Ownable {\n    using EnumerableSet for EnumerableSet.AddressSet;\n    using SafeERC20 for IERC20;\n\n    // token sale beneficiary\n    address public beneficiary;\n\n    // token sale limits per account in USD with 2 decimals (cents)\n    uint256 public minPerAccount;\n    uint256 public maxPerAccount;\n\n    // cap in USD for token sale with 2 decimals (cents)\n    uint256 public cap;\n\n    // timestamp and duration are expressed in UNIX time, the same units as block.timestamp\n    uint256 public startTime;\n    uint256 public duration;\n\n    // used to prevent gas usage when sale is ended\n    bool private _ended;\n\n    // account balance in USD with 2 decimals (cents)\n    mapping(address => uint256) public balances;\n    EnumerableSet.AddressSet private _participants;\n\n    struct ParticipantData {\n        address _address;\n        uint256 _balance;\n    }\n\n    // collected stable coins balances\n    mapping(address => uint256) private _deposited;\n\n    // collected amount in USD with 2 decimals (cents)\n    uint256 public collected;\n\n    // whitelist users in rounds\n    mapping(uint256 => mapping(address => bool)) public whitelisted;\n    uint256 public whitelistRound = 1;\n    bool public whitelistedOnly = true;\n\n    // list of supported stable coins\n    EnumerableSet.AddressSet private stableCoins;\n\n    event WhitelistChanged(bool newEnabled);\n    event WhitelistRoundChanged(uint256 round);\n    event Purchased(address indexed purchaser, uint256 amount);\n\n    /// @dev creates a token sale contract that accepts only USD stable coins\n    /// @param _owner address of the owner\n    /// @param _beneficiary address of the owner\n    /// @param _minPerAccount min limit in USD cents that account needs to spend\n    /// @param _maxPerAccount max allocation in USD cents per account\n    /// @param _cap sale limit amount in USD cents\n    /// @param _startTime the time (as Unix time) of sale start\n    /// @param _duration duration in seconds of token sale\n    /// @param _stableCoinsAddresses array of ERC20 token addresses of stable coins accepted in the sale\n    constructor(\n        address _owner,\n        address _beneficiary,\n        uint256 _minPerAccount,\n        uint256 _maxPerAccount,\n        uint256 _cap,\n        uint256 _startTime,\n        uint256 _duration,\n        address[] memory _stableCoinsAddresses\n    ) Ownable(_owner) {\n        require(_beneficiary != address(0), \"Sale: zero address\");\n        require(_cap > 0, \"Sale: Cap is 0\");\n        require(_duration > 0, \"Sale: Duration is 0\");\n        require(_startTime + _duration > block.timestamp, \"Sale: Final time is before current time\");\n\n        beneficiary = _beneficiary;\n        minPerAccount = _minPerAccount;\n        maxPerAccount = _maxPerAccount;\n        cap = _cap;\n        startTime = _startTime;\n        duration = _duration;\n\n        for (uint256 i; i < _stableCoinsAddresses.length; i++) {\n            stableCoins.add(_stableCoinsAddresses[i]);\n        }\n    }\n\n    // -----------------------------------------------------------------------\n    // GETTERS\n    // -----------------------------------------------------------------------\n\n    /// @return the end time of the sale\n    function endTime() external view returns (uint256) {\n        return startTime + duration;\n    }\n\n    /// @return the balance of the account in USD cents\n    function balanceOf(address account) external view returns (uint256) {\n        return balances[account];\n    }\n\n    /// @return the max allocation for account\n    function maxAllocationOf(address account) external view returns (uint256) {\n        if (!whitelistedOnly || whitelisted[whitelistRound][account]) {\n            return maxPerAccount;\n        } else {\n            return 0;\n        }\n    }\n\n    /// @return the amount in USD cents of remaining allocation\n    function remainingAllocation(address account) external view returns (uint256) {\n        if (!whitelistedOnly || whitelisted[whitelistRound][account]) {\n            if (maxPerAccount > 0) {\n                return maxPerAccount - balances[account];\n            } else {\n                return cap - collected;\n            }\n        } else {\n            return 0;\n        }\n    }\n\n    /// @return information if account is whitelisted\n    function isWhitelisted(address account) external view returns (bool) {\n        if (whitelistedOnly) {\n            return whitelisted[whitelistRound][account];\n        } else {\n            return true;\n        }\n    }\n\n    /// @return addresses with all stable coins supported in the sale\n    function acceptableStableCoins() external view returns (address[] memory) {\n        uint256 length = stableCoins.length();\n        address[] memory addresses = new address[](length);\n\n        for (uint256 i = 0; i < length; i++) {\n            addresses[i] = stableCoins.at(i);\n        }\n\n        return addresses;\n    }\n\n    /// @return info if sale is still ongoing\n    function isLive() public view returns (bool) {\n        return !_ended && block.timestamp > startTime && block.timestamp < startTime + duration;\n    }\n\n    function getParticipantsNumber() external view returns (uint256) {\n        return _participants.length();\n    }\n\n    /// @return participants data at index\n    function getParticipantDataAt(uint256 index) external view returns (ParticipantData memory) {\n        require(index < _participants.length(), \"Incorrect index\");\n\n        address pAddress = _participants.at(index);\n        ParticipantData memory data = ParticipantData(pAddress, balances[pAddress]);\n\n        return data;\n    }\n\n    /// @return participants data in range\n    function getParticipantsDataInRange(uint256 from, uint256 to) external view returns (ParticipantData[] memory) {\n        require(from <= to, \"Incorrect range\");\n        require(to < _participants.length(), \"Incorrect range\");\n\n        uint256 length = to - from + 1;\n        ParticipantData[] memory data = new ParticipantData[](length);\n\n        for (uint256 i; i < length; i++) {\n            address pAddress = _participants.at(i + from);\n            data[i] = ParticipantData(pAddress, balances[pAddress]);\n        }\n\n        return data;\n    }\n\n    // -----------------------------------------------------------------------\n    // INTERNAL\n    // -----------------------------------------------------------------------\n\n    function _isBalanceSufficient(uint256 _amount) private view returns (bool) {\n        return _amount + collected <= cap;\n    }\n\n    // -----------------------------------------------------------------------\n    // MODIFIERS\n    // -----------------------------------------------------------------------\n\n    modifier onlyBeneficiary() {\n        require(msg.sender == beneficiary, \"Sale: Caller is not the beneficiary\");\n        _;\n    }\n\n    modifier onlyWhitelisted() {\n        require(!whitelistedOnly || whitelisted[whitelistRound][msg.sender], \"Sale: Account is not whitelisted\");\n        _;\n    }\n\n    modifier isOngoing() {\n        require(isLive(), \"Sale: Sale is not active\");\n        _;\n    }\n\n    modifier isEnded() {\n        require(_ended || block.timestamp > startTime + duration, \"Sale: Not ended\");\n        _;\n    }\n\n    // -----------------------------------------------------------------------\n    // SETTERS\n    // -----------------------------------------------------------------------\n\n    /// @notice buy tokens using USD stable coins\n    /// @dev use approve/transferFrom flow\n    /// @param stableCoinAddress stable coin token address\n    /// @param amount amount of USD cents\n    function buyWith(address stableCoinAddress, uint256 amount) external isOngoing onlyWhitelisted {\n        require(stableCoins.contains(stableCoinAddress), \"Sale: Stable coin not supported\");\n        require(amount > 0, \"Sale: Amount is 0\");\n        require(_isBalanceSufficient(amount), \"Sale: Insufficient remaining amount\");\n        require(amount + balances[msg.sender] >= minPerAccount, \"Sale: Amount too low\");\n        require(maxPerAccount == 0 || balances[msg.sender] + amount <= maxPerAccount, \"Sale: Amount too high\");\n\n        uint8 decimals = IERC20(stableCoinAddress).safeDecimals();\n        uint256 stableCoinUnits = amount * (10**(decimals - 2));\n\n        // solhint-disable-next-line max-line-length\n        require(IERC20(stableCoinAddress).allowance(msg.sender, address(this)) >= stableCoinUnits, \"Sale: Insufficient stable coin allowance\");\n        IERC20(stableCoinAddress).safeTransferFrom(msg.sender, stableCoinUnits);\n\n        balances[msg.sender] += amount;\n        collected += amount;\n        _deposited[stableCoinAddress] += stableCoinUnits;\n\n        if (!_participants.contains(msg.sender)) {\n            _participants.add(msg.sender);\n        }\n\n        emit Purchased(msg.sender, amount);\n    }\n\n    function endPresale() external onlyOwner {\n        require(collected >= cap, \"Sale: Limit not reached\");\n        _ended = true;\n    }\n\n    function withdrawFunds() external onlyBeneficiary isEnded {\n        _ended = true;\n\n        uint256 amount;\n\n        for (uint256 i; i < stableCoins.length(); i++) {\n            address stableCoin = address(stableCoins.at(i));\n            amount = IERC20(stableCoin).balanceOf(address(this));\n            if (amount > 0) {\n                IERC20(stableCoin).safeTransfer(beneficiary, amount);\n            }\n        }\n    }\n\n    function recoverErc20(address token) external onlyOwner {\n        uint256 amount = IERC20(token).balanceOf(address(this));\n        amount -= _deposited[token];\n        if (amount > 0) {\n            IERC20(token).safeTransfer(owner, amount);\n        }\n    }\n\n    function recoverEth() external onlyOwner isEnded {\n        payable(owner).transfer(address(this).balance);\n    }\n\n    function setBeneficiary(address newBeneficiary) public onlyOwner {\n        require(newBeneficiary != address(0), \"Sale: zero address\");\n        beneficiary = newBeneficiary;\n    }\n\n    function setWhitelistedOnly(bool enabled) public onlyOwner {\n        whitelistedOnly = enabled;\n        emit WhitelistChanged(enabled);\n    }\n\n    function setWhitelistRound(uint256 round) public onlyOwner {\n        whitelistRound = round;\n        emit WhitelistRoundChanged(round);\n    }\n\n    function addWhitelistedAddresses(address[] calldata addresses) external onlyOwner {\n        for (uint256 i; i < addresses.length; i++) {\n            whitelisted[whitelistRound][addresses[i]] = true;\n        }\n    }\n}\n"
    },
    "contracts/abstract/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n// Source: https://github.com/boringcrypto/BoringSolidity/blob/master/contracts/BoringOwnable.sol\n\npragma solidity ^0.8.4;\n\nabstract contract OwnableData {\n    address public owner;\n    address public pendingOwner;\n}\n\nabstract contract Ownable is OwnableData {\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    constructor(address _owner) {\n        require(_owner != address(0), \"Ownable: zero address\");\n        owner = _owner;\n        emit OwnershipTransferred(address(0), msg.sender);\n    }\n\n    /// @notice Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.\n    /// Can only be invoked by the current `owner`.\n    /// @param newOwner Address of the new owner.\n    /// @param direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.\n    function transferOwnership(address newOwner, bool direct) public onlyOwner {\n        if (direct) {\n            // Checks\n            require(newOwner != address(0), \"Ownable: zero address\");\n\n            // Effects\n            emit OwnershipTransferred(owner, newOwner);\n            owner = newOwner;\n            pendingOwner = address(0);\n        } else {\n            // Effects\n            pendingOwner = newOwner;\n        }\n    }\n\n    /// @notice Needs to be called by `pendingOwner` to claim ownership.\n    function claimOwnership() public {\n        address _pendingOwner = pendingOwner;\n\n        // Checks\n        require(msg.sender == _pendingOwner, \"Ownable: caller != pending owner\");\n\n        // Effects\n        emit OwnershipTransferred(owner, _pendingOwner);\n        owner = _pendingOwner;\n        pendingOwner = address(0);\n    }\n\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Ownable: caller is not the owner\");\n        _;\n    }\n}\n"
    },
    "contracts/interfaces/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\ninterface IERC20 {\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address account) external view returns (uint256);\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transfer(address to, uint256 value) external returns (bool);\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n\n    // EIP 2612\n    // solhint-disable-next-line func-name-mixedcase\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\n    function nonces(address owner) external view returns (uint256);\n    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;\n}"
    },
    "contracts/libraries/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"../interfaces/IERC20.sol\";\n\nlibrary SafeERC20 {\n    function safeSymbol(IERC20 token) internal view returns (string memory) {\n        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x95d89b41));\n        return success && data.length > 0 ? abi.decode(data, (string)) : \"???\";\n    }\n\n    function safeName(IERC20 token) internal view returns (string memory) {\n        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x06fdde03));\n        return success && data.length > 0 ? abi.decode(data, (string)) : \"???\";\n    }\n\n    function safeDecimals(IERC20 token) internal view returns (uint8) {\n        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x313ce567));\n        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;\n    }\n\n    function safeTransfer(IERC20 token, address to, uint256 amount) internal {\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), \"SafeERC20: Transfer failed\");\n    }\n\n    function safeTransferFrom(IERC20 token, address from, uint256 amount) internal {\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x23b872dd, from, address(this), amount));\n        require(success && (data.length == 0 || abi.decode(data, (bool))), \"SafeERC20: TransferFrom failed\");\n    }\n}\n"
    }
  }
}}