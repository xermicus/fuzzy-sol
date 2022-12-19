{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 800
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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.7.0;\n\nimport \"../utils/Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.7.0;\n\n/**\n * @dev Library for managing\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\n * types.\n *\n * Sets have the following properties:\n *\n * - Elements are added, removed, and checked for existence in constant time\n * (O(1)).\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\n *\n * ```\n * contract Example {\n *     // Add the library methods\n *     using EnumerableSet for EnumerableSet.AddressSet;\n *\n *     // Declare a set state variable\n *     EnumerableSet.AddressSet private mySet;\n * }\n * ```\n *\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\n * and `uint256` (`UintSet`) are supported.\n */\nlibrary EnumerableSet {\n    // To implement this library for multiple types with as little code\n    // repetition as possible, we write it in terms of a generic Set type with\n    // bytes32 values.\n    // The Set implementation uses private functions, and user-facing\n    // implementations (such as AddressSet) are just wrappers around the\n    // underlying Set.\n    // This means that we can only create new EnumerableSets for types that fit\n    // in bytes32.\n\n    struct Set {\n        // Storage of set values\n        bytes32[] _values;\n\n        // Position of the value in the `values` array, plus 1 because index 0\n        // means a value is not in the set.\n        mapping (bytes32 => uint256) _indexes;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function _add(Set storage set, bytes32 value) private returns (bool) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            // The value is stored at length-1, but we add 1 to all indexes\n            // and use 0 as a sentinel value\n            set._indexes[value] = set._values.length;\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\n        // We read and store the value's index to prevent multiple reads from the same storage slot\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) { // Equivalent to contains(set, value)\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\n            // the array, and then remove the last element (sometimes called as 'swap and pop').\n            // This modifies the order of the array, as noted in {at}.\n\n            uint256 toDeleteIndex = valueIndex - 1;\n            uint256 lastIndex = set._values.length - 1;\n\n            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs\n            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.\n\n            bytes32 lastvalue = set._values[lastIndex];\n\n            // Move the last value to the index where the value to delete is\n            set._values[toDeleteIndex] = lastvalue;\n            // Update the index for the moved value\n            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based\n\n            // Delete the slot where the moved value was stored\n            set._values.pop();\n\n            // Delete the index for the deleted slot\n            delete set._indexes[value];\n\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\n        require(set._values.length > index, \"EnumerableSet: index out of bounds\");\n        return set._values[index];\n    }\n\n    // Bytes32Set\n\n    struct Bytes32Set {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _add(set._inner, value);\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _remove(set._inner, value);\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\n        return _contains(set._inner, value);\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(Bytes32Set storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\n        return _at(set._inner, index);\n    }\n\n    // AddressSet\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(AddressSet storage set, address value) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(AddressSet storage set, address value) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\n        return address(uint160(uint256(_at(set._inner, index))));\n    }\n\n\n    // UintSet\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n   /**\n    * @dev Returns the value stored at position `index` in the set. O(1).\n    *\n    * Note that there are no guarantees on the ordering of values inside the\n    * array, and it may change when more values are added or removed.\n    *\n    * Requirements:\n    *\n    * - `index` must be strictly less than {length}.\n    */\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n}\n"
    },
    "contracts/NirnVaultFactory.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.7.6;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/utils/EnumerableSet.sol\";\nimport \"./interfaces/IProxyManager.sol\";\nimport \"./interfaces/IAdapterRegistry.sol\";\nimport \"./interfaces/INirnVault.sol\";\nimport \"./libraries/ArrayHelper.sol\";\n\n\ncontract NirnVaultFactory is Ownable() {\n  using EnumerableSet for EnumerableSet.AddressSet;\n  using ArrayHelper for EnumerableSet.AddressSet;\n\n/* ========== Events ========== */\n\n  event TokenApproved(address token);\n\n  event SetDefaultRewardsSeller(address defaultRewardsSeller);\n\n  event SetDefaultFeeRecipient(address defaultFeeRecipient);\n\n/* ========== Constants ========== */\n\n  address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\n  uint256 public constant minimumAdapters = 2;\n  bytes32 public constant erc20VaultImplementationId = keccak256(\"NirnVaultV1.sol\");\n  bytes32 public constant ethVaultImplementationId = keccak256(\"EthNirnVaultV1.sol\");\n  IProxyManager public immutable proxyManager;\n  IAdapterRegistry public immutable registry;\n\n/* ========== Storage ========== */\n\n  EnumerableSet.AddressSet internal _approvedTokens;\n  address public defaultFeeRecipient;\n  address public defaultRewardsSeller;\n\n/* ========== Constructor ========== */\n\n  constructor(address _proxyManager, address _registry) {\n    proxyManager = IProxyManager(_proxyManager);\n    registry = IAdapterRegistry(_registry);\n  }\n\n/* ========== Configuration ========== */\n\n  function approveToken(address token) external onlyOwner {\n    require(!_approvedTokens.contains(token), \"already approved\");\n    require(token != address(0), \"null address\");\n    _approvedTokens.add(token);\n    emit TokenApproved(token);\n  }\n\n  function setDefaultRewardsSeller(address _defaultRewardsSeller) external onlyOwner {\n    require(_defaultRewardsSeller != address(0), \"null address\");\n    defaultRewardsSeller = _defaultRewardsSeller;\n    emit SetDefaultRewardsSeller(_defaultRewardsSeller);\n  }\n\n  function setDefaultFeeRecipient(address _defaultFeeRecipient) external onlyOwner {\n    require(_defaultFeeRecipient != address(0), \"null address\");\n    defaultFeeRecipient = _defaultFeeRecipient;\n    emit SetDefaultFeeRecipient(_defaultFeeRecipient);\n  }\n\n/* ========== Queries ========== */\n\n  function isTokenApproved(address token) external view returns (bool) {\n    return _approvedTokens.contains(token);\n  }\n\n  function getApprovedTokens() external view returns (address[] memory approvedTokens) {\n    approvedTokens = _approvedTokens.toArray();\n  }\n\n  function computeVaultAddress(address underlying) external view returns (address vault) {\n    bytes32 implementationId = getImplementationId(underlying);\n    bytes32 salt = keccak256(abi.encode(underlying));\n    vault = proxyManager.computeProxyAddressManyToOne(address(this), implementationId, salt);\n  }\n\n  function getImplementationId(address underlying) internal pure returns (bytes32 implementationId) {\n    return underlying == weth\n      ? ethVaultImplementationId\n      : erc20VaultImplementationId;\n  }\n\n/* ========== Actions ========== */\n\n  function deployVault(address underlying) external {\n    require(_approvedTokens.contains(underlying), \"!approved\");\n    require(registry.getAdaptersCount(underlying) >= minimumAdapters, \"insufficient adapters\");\n    address _defaultFeeRecipient = defaultFeeRecipient;\n    require(_defaultFeeRecipient != address(0), \"null default\");\n    bytes32 implementationId = getImplementationId(underlying);\n    bytes32 salt = keccak256(abi.encode(underlying));\n    address vault = proxyManager.deployProxyManyToOne(implementationId, salt);\n    INirnVault(vault).initialize(underlying, defaultRewardsSeller, _defaultFeeRecipient, owner());\n    registry.addVault(vault);\n  }\n}"
    },
    "contracts/interfaces/IAdapterRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.7.6;\n\n\ninterface IAdapterRegistry {\n/* ========== Events ========== */\n\n  event ProtocolAdapterAdded(uint256 protocolId, address protocolAdapter);\n\n  event ProtocolAdapterRemoved(uint256 protocolId);\n\n  event TokenAdapterAdded(address adapter, uint256 protocolId, address underlying, address wrapper);\n\n  event TokenAdapterRemoved(address adapter, uint256 protocolId, address underlying, address wrapper);\n\n  event TokenSupportAdded(address underlying);\n\n  event TokenSupportRemoved(address underlying);\n\n  event VaultFactoryAdded(address factory);\n\n  event VaultFactoryRemoved(address factory);\n\n  event VaultAdded(address underlying, address vault);\n\n  event VaultRemoved(address underlying, address vault);\n\n/* ========== Structs ========== */\n\n  struct TokenAdapter {\n    address adapter;\n    uint96 protocolId;\n  }\n\n/* ========== Storage ========== */\n\n  function protocolsCount() external view returns (uint256);\n\n  function protocolAdapters(uint256 id) external view returns (address protocolAdapter);\n\n  function protocolAdapterIds(address protocolAdapter) external view returns (uint256 id);\n\n  function vaultsByUnderlying(address underlying) external view returns (address vault);\n\n  function approvedVaultFactories(address factory) external view returns (bool approved);\n\n/* ========== Vault Factory Management ========== */\n\n  function addVaultFactory(address _factory) external;\n\n  function removeVaultFactory(address _factory) external;\n\n/* ========== Vault Management ========== */\n\n  function addVault(address vault) external;\n\n  function removeVault(address vault) external;\n\n/* ========== Protocol Adapter Management ========== */\n\n  function addProtocolAdapter(address protocolAdapter) external returns (uint256 id);\n\n  function removeProtocolAdapter(address protocolAdapter) external;\n\n/* ========== Token Adapter Management ========== */\n\n  function addTokenAdapter(address adapter) external;\n\n  function addTokenAdapters(address[] calldata adapters) external;\n\n  function removeTokenAdapter(address adapter) external;\n\n/* ========== Vault Queries ========== */\n\n  function getVaultsList() external view returns (address[] memory);\n\n  function haveVaultFor(address underlying) external view returns (bool);\n\n/* ========== Protocol Queries ========== */\n\n  function getProtocolAdaptersAndIds() external view returns (address[] memory adapters, uint256[] memory ids);\n\n  function getProtocolMetadata(uint256 id) external view returns (address protocolAdapter, string memory name);\n\n  function getProtocolForTokenAdapter(address adapter) external view returns (address protocolAdapter);\n\n/* ========== Supported Token Queries ========== */\n\n  function isSupported(address underlying) external view returns (bool);\n\n  function getSupportedTokens() external view returns (address[] memory list);\n\n/* ========== Token Adapter Queries ========== */\n\n  function isApprovedAdapter(address adapter) external view returns (bool);\n\n  function getAdaptersList(address underlying) external view returns (address[] memory list);\n\n  function getAdapterForWrapperToken(address wrapperToken) external view returns (address);\n\n  function getAdaptersCount(address underlying) external view returns (uint256);\n\n  function getAdaptersSortedByAPR(address underlying)\n    external\n    view\n    returns (address[] memory adapters, uint256[] memory aprs);\n\n  function getAdaptersSortedByAPRWithDeposit(\n    address underlying,\n    uint256 deposit,\n    address excludingAdapter\n  )\n    external\n    view\n    returns (address[] memory adapters, uint256[] memory aprs);\n\n  function getAdapterWithHighestAPR(address underlying) external view returns (address adapter, uint256 apr);\n\n  function getAdapterWithHighestAPRForDeposit(\n    address underlying,\n    uint256 deposit,\n    address excludingAdapter\n  ) external view returns (address adapter, uint256 apr);\n}\n\n"
    },
    "contracts/interfaces/INirnVault.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.7.6;\npragma abicoder v2;\n\nimport \"./IAdapterRegistry.sol\";\nimport \"./ITokenAdapter.sol\";\nimport \"./IRewardsSeller.sol\";\n\n\ninterface INirnVault {\n/* ========== Events ========== */\n\n  /** @dev Emitted when an adapter is removed and its balance fully withdrawn. */\n  event AdapterRemoved(IErc20Adapter adapter);\n\n  /** @dev Emitted when weights or adapters are updated. */\n  event AllocationsUpdated(IErc20Adapter[] adapters, uint256[] weights);\n\n  /** @dev Emitted when performance fees are claimed. */\n  event FeesClaimed(uint256 underlyingAmount, uint256 sharesMinted);\n\n  /** @dev Emitted when a rebalance happens without allocation changes. */\n  event Rebalanced();\n\n  /** @dev Emitted when max underlying is updated. */\n  event SetMaximumUnderlying(uint256 maxBalance);\n\n  /** @dev Emitted when fee recipient address is set. */\n  event SetFeeRecipient(address feeRecipient);\n\n  /** @dev Emitted when performance fee is set. */\n  event SetPerformanceFee(uint256 performanceFee);\n\n  /** @dev Emitted when reserve ratio is set. */\n  event SetReserveRatio(uint256 reserveRatio);\n\n  /** @dev Emitted when rewards seller contract is set. */\n  event SetRewardsSeller(address rewardsSeller);\n\n  /** @dev Emitted when a deposit is made. */\n  event Deposit(uint256 shares, uint256 underlying);\n\n  /** @dev Emitted when a deposit is made. */\n  event Withdrawal(uint256 shares, uint256 underlying);\n\n/* ========== Structs ========== */\n\n  struct DistributionParameters {\n    IErc20Adapter[] adapters;\n    uint256[] weights;\n    uint256[] balances;\n    int256[] liquidityDeltas;\n    uint256 netAPR;\n  }\n\n/* ========== Initializer ========== */\n\n  function initialize(\n    address _underlying,\n    address _rewardsSeller,\n    address _feeRecipient,\n    address _owner\n  ) external;\n\n/* ========== Config Queries ========== */\n\n  function minimumAPRImprovement() external view returns (uint256);\n\n  function registry() external view returns (IAdapterRegistry);\n\n  function eoaSafeCaller() external view returns (address);\n\n  function underlying() external view returns (address);\n\n  function name() external view returns (string memory);\n\n  function symbol() external view returns (string memory);\n\n  function decimals() external view returns (uint8);\n\n  function feeRecipient() external view returns (address);\n\n  function rewardsSeller() external view returns (IRewardsSeller);\n\n  function lockedTokens(address) external view returns (bool);\n\n  function maximumUnderlying() external view returns (uint256);\n\n  function performanceFee() external view returns (uint64);\n\n  function reserveRatio() external view returns (uint64);\n\n  function priceAtLastFee() external view returns (uint128);\n\n  function minimumCompositionChangeDelay() external view returns (uint256);\n\n  function canChangeCompositionAfter() external view returns (uint96);\n\n/* ========== Admin Actions ========== */\n\n  function setMaximumUnderlying(uint256 _maximumUnderlying) external;\n\n  function setPerformanceFee(uint64 _performanceFee) external;\n\n  function setFeeRecipient(address _feeRecipient) external;\n\n  function setRewardsSeller(IRewardsSeller _rewardsSeller) external;\n\n  function setReserveRatio(uint64 _reserveRatio) external;\n\n/* ========== Balance Queries ========== */\n\n  function balance() external view returns (uint256 sum);\n\n  function reserveBalance() external view returns (uint256);\n\n/* ========== Fee Queries ========== */\n\n  function getPendingFees() external view returns (uint256);\n\n/* ========== Price Queries ========== */\n\n  function getPricePerFullShare() external view returns (uint256);\n\n  function getPricePerFullShareWithFee() external view returns (uint256);\n\n/* ========== Reward Token Sales ========== */\n\n  function sellRewards(address rewardsToken, bytes calldata params) external;\n\n/* ========== Adapter Queries ========== */\n\n  function getBalances() external view returns (uint256[] memory balances);\n\n  function getAdaptersAndWeights() external view returns (\n    IErc20Adapter[] memory adapters,\n    uint256[] memory weights\n  );\n\n/* ========== Status Queries ========== */\n\n  function getCurrentLiquidityDeltas() external view returns (int256[] memory liquidityDeltas);\n\n  function getAPR() external view returns (uint256);\n\n  function currentDistribution() external view returns (\n    DistributionParameters memory params,\n    uint256 totalProductiveBalance,\n    uint256 _reserveBalance\n  );\n\n/* ========== Deposit/Withdraw ========== */\n\n  function deposit(uint256 amount) external returns (uint256 shares);\n\n  function depositTo(uint256 amount, address to) external returns (uint256 shares);\n\n  function withdraw(uint256 shares) external returns (uint256 owed);\n\n  function withdrawUnderlying(uint256 amount) external returns (uint256 shares);\n\n/* ========== Rebalance Actions ========== */\n\n  function rebalance() external;\n\n  function rebalanceWithNewWeights(uint256[] calldata proposedWeights) external;\n\n  function rebalanceWithNewAdapters(\n    IErc20Adapter[] calldata proposedAdapters,\n    uint256[] calldata proposedWeights\n  ) external;\n}"
    },
    "contracts/interfaces/IProxyManager.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.5.10;\n\n\ninterface IProxyManager {\n  function deployProxyManyToOne(\n    bytes32 implementationID,\n    bytes32 suppliedSalt\n  ) external returns(address proxyAddress);\n\n  function computeProxyAddressManyToOne(\n    address originator,\n    bytes32 implementationID,\n    bytes32 suppliedSalt\n  ) external view returns (address);\n}"
    },
    "contracts/interfaces/IRewardsSeller.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity =0.7.6;\n\n\ninterface IRewardsSeller {\n  /**\n   * @dev Sell `rewardsToken` for `underlyingToken`.\n   * Should only be called after `rewardsToken` is transferred.\n   * @param sender - Address of account that initially triggered the call. Can be used to restrict who can trigger a sale.\n   * @param rewardsToken - Address of the token to sell.\n   * @param underlyingToken - Address of the token to buy.\n   * @param params - Any additional data that the caller provided.\n   */\n  function sellRewards(\n    address sender,\n    address rewardsToken,\n    address underlyingToken,\n    bytes calldata params\n  ) external;\n}"
    },
    "contracts/interfaces/ITokenAdapter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.5.0;\n\n\ninterface IErc20Adapter {\n/* ========== Metadata ========== */\n\n  function underlying() external view returns (address);\n\n  function token() external view returns (address);\n\n  function name() external view returns (string memory);\n\n  function availableLiquidity() external view returns (uint256);\n\n/* ========== Conversion ========== */\n\n  function toUnderlyingAmount(uint256 tokenAmount) external view returns (uint256);\n\n  function toWrappedAmount(uint256 underlyingAmount) external view returns (uint256);\n\n/* ========== Performance Queries ========== */\n\n  function getAPR() external view returns (uint256);\n\n  function getHypotheticalAPR(int256 liquidityDelta) external view returns (uint256);\n\n  function getRevenueBreakdown()\n    external\n    view\n    returns (\n      address[] memory assets,\n      uint256[] memory aprs\n    );\n\n/* ========== Caller Balance Queries ========== */\n\n  function balanceWrapped() external view returns (uint256);\n\n  function balanceUnderlying() external view returns (uint256);\n\n/* ========== Interactions ========== */\n\n  function deposit(uint256 amountUnderlying) external returns (uint256 amountMinted);\n\n  function withdraw(uint256 amountToken) external returns (uint256 amountReceived);\n\n  function withdrawAll() external returns (uint256 amountReceived);\n\n  function withdrawUnderlying(uint256 amountUnderlying) external returns (uint256 amountBurned);\n\n  function withdrawUnderlyingUpTo(uint256 amountUnderlying) external returns (uint256 amountReceived);\n}\n\ninterface IEtherAdapter is IErc20Adapter {\n  function depositETH() external payable returns (uint256 amountMinted);\n\n  function withdrawAsETH(uint256 amountToken) external returns (uint256 amountReceived);\n\n  function withdrawAllAsETH() external returns (uint256 amountReceived);\n\n  function withdrawUnderlyingAsETH(uint256 amountUnderlying) external returns (uint256 amountBurned); \n}"
    },
    "contracts/libraries/ArrayHelper.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity >=0.5.0;\n\nimport \"@openzeppelin/contracts/utils/EnumerableSet.sol\";\nimport \"../libraries/LowGasSafeMath.sol\";\nimport \"../interfaces/ITokenAdapter.sol\";\n\n\nlibrary ArrayHelper {\n  using EnumerableSet for EnumerableSet.AddressSet;\n  using LowGasSafeMath for uint256;\n\n/* ========== Type Cast ========== */\n\n  /**\n   * @dev Cast an enumerable address set as an address array.\n   * The enumerable set library stores the values as a bytes32 array, this function\n   * casts it as an address array with a pointer assignment.\n   */\n  function toArray(EnumerableSet.AddressSet storage set) internal view returns (address[] memory arr) {\n    bytes32[] memory bytes32Arr = set._inner._values;\n    assembly { arr := bytes32Arr }\n  }\n\n  /**\n   * @dev Cast an array of IErc20Adapter to an array of address using a pointer assignment.\n   * Note: The resulting array is the same as the original, so all changes to one will be\n   * reflected in the other.\n   */\n  function toAddressArray(IErc20Adapter[] memory _arr) internal pure returns (address[] memory arr) {\n    assembly { arr := _arr }\n  }\n\n/* ========== Math ========== */\n\n  /**\n   * @dev Computes the sum of a uint256 array.\n   */\n  function sum(uint256[] memory arr) internal pure returns (uint256 _sum) {\n    uint256 len = arr.length;\n    for (uint256 i; i < len; i++) _sum = _sum.add(arr[i]);\n  }\n\n/* ========== Removal ========== */\n\n  /**\n   * @dev Remove the element at `index` from an array and decrement its length.\n   * If `index` is the last index in the array, pops it from the array.\n   * Otherwise, stores the last element in the array at `index` and then pops the last element.\n   */\n  function mremove(uint256[] memory arr, uint256 index) internal pure {\n    uint256 len = arr.length;\n    if (index != len - 1) {\n      uint256 last = arr[len - 1];\n      arr[index] = last;\n    }\n    assembly { mstore(arr, sub(len, 1)) }\n  }\n\n  /**\n   * @dev Remove the element at `index` from an array and decrement its length.\n   * If `index` is the last index in the array, pops it from the array.\n   * Otherwise, stores the last element in the array at `index` and then pops the last element.\n   */\n  function mremove(address[] memory arr, uint256 index) internal pure {\n    uint256 len = arr.length;\n    if (index != len - 1) {\n      address last = arr[len - 1];\n      arr[index] = last;\n    }\n    assembly { mstore(arr, sub(len, 1)) }\n  }\n\n  /**\n   * @dev Remove the element at `index` from an array and decrement its length.\n   * If `index` is the last index in the array, pops it from the array.\n   * Otherwise, stores the last element in the array at `index` and then pops the last element.\n   */\n  function mremove(IErc20Adapter[] memory arr, uint256 index) internal pure {\n    uint256 len = arr.length;\n    if (index != len - 1) {\n      IErc20Adapter last = arr[len - 1];\n      arr[index] = last;\n    }\n    assembly { mstore(arr, sub(len, 1)) }\n  }\n\n  /**\n   * @dev Remove the element at `index` from an array and decrement its length.\n   * If `index` is the last index in the array, pops it from the array.\n   * Otherwise, stores the last element in the array at `index` and then pops the last element.\n   */\n  function remove(bytes32[] storage arr, uint256 index) internal {\n    uint256 len = arr.length;\n    if (index == len - 1) {\n      arr.pop();\n      return;\n    }\n    bytes32 last = arr[len - 1];\n    arr[index] = last;\n    arr.pop();\n  }\n\n  /**\n   * @dev Remove the element at `index` from an array and decrement its length.\n   * If `index` is the last index in the array, pops it from the array.\n   * Otherwise, stores the last element in the array at `index` and then pops the last element.\n   */\n  function remove(address[] storage arr, uint256 index) internal {\n    uint256 len = arr.length;\n    if (index == len - 1) {\n      arr.pop();\n      return;\n    }\n    address last = arr[len - 1];\n    arr[index] = last;\n    arr.pop();\n  }\n\n/* ========== Search ========== */\n\n  /**\n   * @dev Find the index of an address in an array.\n   * If the address is not found, revert.\n   */\n  function indexOf(address[] memory arr, address find) internal pure returns (uint256) {\n    uint256 len = arr.length;\n    for (uint256 i; i < len; i++) if (arr[i] == find) return i;\n    revert(\"element not found\");\n  }\n\n  /**\n   * @dev Determine whether an element is included in an array.\n   */\n  function includes(address[] memory arr, address find) internal pure returns (bool) {\n    uint256 len = arr.length;\n    for (uint256 i; i < len; i++) if (arr[i] == find) return true;\n    return false;\n  }\n\n/* ========== Sorting ========== */\n\n  /**\n   * @dev Given an array of tokens and scores, sort by scores in descending order.\n   * Maintains the relationship between elements of each array at the same index.\n   */\n  function sortByDescendingScore(\n    address[] memory addresses,\n    uint256[] memory scores\n  ) internal pure {\n    uint256 len = addresses.length;\n    for (uint256 i = 0; i < len; i++) {\n      uint256 score = scores[i];\n      address _address = addresses[i];\n      uint256 j = i - 1;\n      while (int(j) >= 0 && scores[j] < score) {\n        scores[j + 1] = scores[j];\n        addresses[j + 1] = addresses[j];\n        j--;\n      }\n      scores[j + 1] = score;\n      addresses[j + 1] = _address;\n    }\n  }\n}"
    },
    "contracts/libraries/LowGasSafeMath.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.7.0;\n\n/************************************************************************************************\nOriginally from https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/LowGasSafeMath.sol\n\nThis source code has been modified from the original, which was copied from the github repository\nat commit hash b83fcf497e895ae59b97c9d04e997023f69b5e97.\n\nSubject to the GPL-2.0 license\n*************************************************************************************************/\n\n\n/// @title Optimized overflow and underflow safe math operations\n/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost\nlibrary LowGasSafeMath {\n  /// @notice Returns x + y, reverts if sum overflows uint256\n  /// @param x The augend\n  /// @param y The addend\n  /// @return z The sum of x and y\n  function add(uint256 x, uint256 y) internal pure returns (uint256 z) {\n    require((z = x + y) >= x);\n  }\n\n  /// @notice Returns x + y, reverts if sum overflows uint256\n  /// @param x The augend\n  /// @param y The addend\n  /// @return z The sum of x and y\n  function add(uint256 x, uint256 y, string memory errorMessage) internal pure returns (uint256 z) {\n    require((z = x + y) >= x, errorMessage);\n  }\n\n  /// @notice Returns x - y, reverts if underflows\n  /// @param x The minuend\n  /// @param y The subtrahend\n  /// @return z The difference of x and y\n  function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {\n    require(y <= x);\n    z = x - y;\n  }\n\n  /// @notice Returns x - y, reverts if underflows\n  /// @param x The minuend\n  /// @param y The subtrahend\n  /// @return z The difference of x and y\n  function sub(uint256 x, uint256 y, string memory errorMessage) internal pure returns (uint256 z) {\n    require(y <= x, errorMessage);\n    z = x - y;\n  }\n\n  /// @notice Returns x * y, reverts if overflows\n  /// @param x The multiplicand\n  /// @param y The multiplier\n  /// @return z The product of x and y\n  function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {\n    if (x == 0) return 0;\n    z = x * y;\n    require(z / x == y);\n  }\n\n  /// @notice Returns x * y, reverts if overflows\n  /// @param x The multiplicand\n  /// @param y The multiplier\n  /// @return z The product of x and y\n  function mul(uint256 x, uint256 y, string memory errorMessage) internal pure returns (uint256 z) {\n    if (x == 0) return 0;\n    z = x * y;\n    require(z / x == y, errorMessage);\n  }\n\n  /// @notice Returns ceil(x / y)\n  /// @param x The numerator\n  /// @param y The denominator\n  /// @return z The quotient of x and y\n  function divCeil(uint256 x, uint256 y) internal pure returns (uint256 z) {\n    z = x % y == 0 ? x / y : (x/y) + 1;\n  }\n}\n"
    }
  }
}}