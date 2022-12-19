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
    "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n// solhint-disable-next-line compiler-version\npragma solidity ^0.8.0;\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n */\nabstract contract Initializable {\n\n    /**\n     * @dev Indicates that the contract has been initialized.\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice.\n     */\n    modifier initializer() {\n        require(_initializing || !_initialized, \"Initializable: contract is already initialized\");\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Standard math utilities missing in the Solidity language.\n */\nlibrary MathUpgradeable {\n    /**\n     * @dev Returns the largest of two numbers.\n     */\n    function max(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a >= b ? a : b;\n    }\n\n    /**\n     * @dev Returns the smallest of two numbers.\n     */\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a < b ? a : b;\n    }\n\n    /**\n     * @dev Returns the average of two numbers. The result is rounded towards\n     * zero.\n     */\n    function average(uint256 a, uint256 b) internal pure returns (uint256) {\n        // (a + b) / 2 can overflow, so we distribute\n        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);\n    }\n}\n"
    },
    "contracts/core/BiosRewards.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol\";\nimport \"../interfaces/IBiosRewards.sol\";\nimport \"../interfaces/IUserPositions.sol\";\nimport \"../interfaces/IIntegrationMap.sol\";\nimport \"./Controlled.sol\";\nimport \"./ModuleMapConsumer.sol\";\n\ncontract BiosRewards is\n  Initializable,\n  ModuleMapConsumer,\n  Controlled,\n  IBiosRewards\n{\n  uint256 private totalBiosRewards;\n  uint256 private totalClaimedBiosRewards;\n  mapping(address => uint256) private totalUserClaimedBiosRewards;\n  mapping(address => uint256) public periodFinish;\n  mapping(address => uint256) public rewardRate;\n  mapping(address => uint256) public lastUpdateTime;\n  mapping(address => uint256) public rewardPerTokenStored;\n  mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;\n  mapping(address => mapping(address => uint256)) public rewards;\n\n  event RewardAdded(address indexed token, uint256 reward, uint32 duration);\n\n  function initialize(address[] memory controllers_, address moduleMap_)\n    public\n    initializer\n  {\n    __Controlled_init(controllers_, moduleMap_);\n    __ModuleMapConsumer_init(moduleMap_);\n  }\n\n  modifier updateReward(address token, address account) {\n    rewardPerTokenStored[token] = rewardPerToken(token);\n    lastUpdateTime[token] = lastTimeRewardApplicable(token);\n    if (account != address(0)) {\n      rewards[token][account] = earned(token, account);\n      userRewardPerTokenPaid[token][account] = rewardPerTokenStored[token];\n    }\n    _;\n  }\n\n  /// @param token The address of the ERC20 token contract\n  /// @param reward The updated reward amount\n  /// @param duration The duration of the rewards period\n  function notifyRewardAmount(\n    address token,\n    uint256 reward,\n    uint32 duration\n  ) external override onlyController updateReward(token, address(0)) {\n    if (block.timestamp >= periodFinish[token]) {\n      rewardRate[token] = reward / duration;\n    } else {\n      uint256 remaining = periodFinish[token] - block.timestamp;\n      uint256 leftover = remaining * rewardRate[token];\n      rewardRate[token] = (reward + leftover) / duration;\n    }\n    lastUpdateTime[token] = block.timestamp;\n    periodFinish[token] = block.timestamp + duration;\n    totalBiosRewards += reward;\n    emit RewardAdded(token, reward, duration);\n  }\n\n  function increaseRewards(\n    address token,\n    address account,\n    uint256 amount\n  ) public override onlyController updateReward(token, account) {\n    require(amount > 0, \"BiosRewards::increaseRewards: Cannot increase 0\");\n  }\n\n  function decreaseRewards(\n    address token,\n    address account,\n    uint256 amount\n  ) public override onlyController updateReward(token, account) {\n    require(amount > 0, \"BiosRewards::decreaseRewards: Cannot decrease 0\");\n  }\n\n  function claimReward(address token, address account)\n    public\n    override\n    onlyController\n    updateReward(token, account)\n    returns (uint256 reward)\n  {\n    reward = earned(token, account);\n    if (reward > 0) {\n      rewards[token][account] = 0;\n      totalBiosRewards -= reward;\n      totalClaimedBiosRewards += reward;\n      totalUserClaimedBiosRewards[account] += reward;\n    }\n    return reward;\n  }\n\n  function lastTimeRewardApplicable(address token)\n    public\n    view\n    override\n    returns (uint256)\n  {\n    return MathUpgradeable.min(block.timestamp, periodFinish[token]);\n  }\n\n  function rewardPerToken(address token)\n    public\n    view\n    override\n    returns (uint256)\n  {\n    uint256 totalSupply = IUserPositions(\n      moduleMap.getModuleAddress(Modules.UserPositions)\n    ).totalTokenBalance(token);\n    if (totalSupply == 0) {\n      return rewardPerTokenStored[token];\n    }\n    return\n      rewardPerTokenStored[token] +\n      (((lastTimeRewardApplicable(token) - lastUpdateTime[token]) *\n        rewardRate[token] *\n        1e18) / totalSupply);\n  }\n\n  function earned(address token, address account)\n    public\n    view\n    override\n    returns (uint256)\n  {\n    IUserPositions userPositions = IUserPositions(\n      moduleMap.getModuleAddress(Modules.UserPositions)\n    );\n    return\n      ((userPositions.userTokenBalance(token, account) *\n        (rewardPerToken(token) - userRewardPerTokenPaid[token][account])) /\n        1e18) + rewards[token][account];\n  }\n\n  function getUserBiosRewards(address account)\n    external\n    view\n    override\n    returns (uint256 userBiosRewards)\n  {\n    IIntegrationMap integrationMap = IIntegrationMap(\n      moduleMap.getModuleAddress(Modules.IntegrationMap)\n    );\n\n    for (\n      uint256 tokenId;\n      tokenId < integrationMap.getTokenAddressesLength();\n      tokenId++\n    ) {\n      userBiosRewards += earned(\n        integrationMap.getTokenAddress(tokenId),\n        account\n      );\n    }\n  }\n\n  function getTotalClaimedBiosRewards()\n    external\n    view\n    override\n    returns (uint256)\n  {\n    return totalClaimedBiosRewards;\n  }\n\n  function getTotalUserClaimedBiosRewards(address account)\n    external\n    view\n    override\n    returns (uint256)\n  {\n    return totalUserClaimedBiosRewards[account];\n  }\n\n  function getBiosRewards() external view override returns (uint256) {\n    return totalBiosRewards;\n  }\n}\n"
    },
    "contracts/core/Controlled.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol\";\nimport \"./ModuleMapConsumer.sol\";\nimport \"../interfaces/IKernel.sol\";\n\nabstract contract Controlled is Initializable, ModuleMapConsumer {\n  // controller address => is a controller\n  mapping(address => bool) internal _controllers;\n  address[] public controllers;\n\n  function __Controlled_init(address[] memory controllers_, address moduleMap_)\n    public\n    initializer\n  {\n    for (uint256 i; i < controllers_.length; i++) {\n      _controllers[controllers_[i]] = true;\n    }\n    controllers = controllers_;\n    __ModuleMapConsumer_init(moduleMap_);\n  }\n\n  function addController(address controller) external onlyOwner {\n    _controllers[controller] = true;\n    bool added;\n    for (uint256 i; i < controllers.length; i++) {\n      if (controller == controllers[i]) {\n        added = true;\n      }\n    }\n    if (!added) {\n      controllers.push(controller);\n    }\n  }\n\n  modifier onlyOwner() {\n    require(\n      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isOwner(msg.sender),\n      \"Controlled::onlyOwner: Caller is not owner\"\n    );\n    _;\n  }\n\n  modifier onlyManager() {\n    require(\n      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isManager(msg.sender),\n      \"Controlled::onlyManager: Caller is not manager\"\n    );\n    _;\n  }\n\n  modifier onlyController() {\n    require(\n      _controllers[msg.sender],\n      \"Controlled::onlyController: Caller is not controller\"\n    );\n    _;\n  }\n}\n"
    },
    "contracts/core/ModuleMapConsumer.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\nimport \"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol\";\nimport \"../interfaces/IModuleMap.sol\";\n\nabstract contract ModuleMapConsumer is Initializable {\n  IModuleMap public moduleMap;\n\n  function __ModuleMapConsumer_init(address moduleMap_) internal initializer {\n    moduleMap = IModuleMap(moduleMap_);\n  }\n}\n"
    },
    "contracts/interfaces/IBiosRewards.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\ninterface IBiosRewards {\n  /// @param token The address of the ERC20 token contract\n  /// @param reward The updated reward amount\n  /// @param duration The duration of the rewards period\n  function notifyRewardAmount(\n    address token,\n    uint256 reward,\n    uint32 duration\n  ) external;\n\n  function increaseRewards(\n    address token,\n    address account,\n    uint256 amount\n  ) external;\n\n  function decreaseRewards(\n    address token,\n    address account,\n    uint256 amount\n  ) external;\n\n  function claimReward(address asset, address account)\n    external\n    returns (uint256 reward);\n\n  function lastTimeRewardApplicable(address token)\n    external\n    view\n    returns (uint256);\n\n  function rewardPerToken(address token) external view returns (uint256);\n\n  function earned(address token, address account)\n    external\n    view\n    returns (uint256);\n\n  function getUserBiosRewards(address account)\n    external\n    view\n    returns (uint256 userBiosRewards);\n\n  function getTotalClaimedBiosRewards() external view returns (uint256);\n\n  function getTotalUserClaimedBiosRewards(address account)\n    external\n    view\n    returns (uint256);\n\n  function getBiosRewards() external view returns (uint256);\n}\n"
    },
    "contracts/interfaces/IIntegrationMap.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\ninterface IIntegrationMap {\n  struct Integration {\n    bool added;\n    string name;\n  }\n\n  struct Token {\n    uint256 id;\n    bool added;\n    bool acceptingDeposits;\n    bool acceptingWithdrawals;\n    uint256 biosRewardWeight;\n    uint256 reserveRatioNumerator;\n  }\n\n  /// @param contractAddress The address of the integration contract\n  /// @param name The name of the protocol being integrated to\n  function addIntegration(address contractAddress, string memory name) external;\n\n  /// @param tokenAddress The address of the ERC20 token contract\n  /// @param acceptingDeposits Whether token deposits are enabled\n  /// @param acceptingWithdrawals Whether token withdrawals are enabled\n  /// @param biosRewardWeight Token weight for BIOS rewards\n  /// @param reserveRatioNumerator Number that gets divided by reserve ratio denominator to get reserve ratio\n  function addToken(\n    address tokenAddress,\n    bool acceptingDeposits,\n    bool acceptingWithdrawals,\n    uint256 biosRewardWeight,\n    uint256 reserveRatioNumerator\n  ) external;\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  function enableTokenDeposits(address tokenAddress) external;\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  function disableTokenDeposits(address tokenAddress) external;\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  function enableTokenWithdrawals(address tokenAddress) external;\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  function disableTokenWithdrawals(address tokenAddress) external;\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  /// @param rewardWeight The updated token BIOS reward weight\n  function updateTokenRewardWeight(address tokenAddress, uint256 rewardWeight)\n    external;\n\n  /// @param tokenAddress the address of the token ERC20 contract\n  /// @param reserveRatioNumerator Number that gets divided by reserve ratio denominator to get reserve ratio\n  function updateTokenReserveRatioNumerator(\n    address tokenAddress,\n    uint256 reserveRatioNumerator\n  ) external;\n\n  /// @param integrationId The ID of the integration\n  /// @return The address of the integration contract\n  function getIntegrationAddress(uint256 integrationId)\n    external\n    view\n    returns (address);\n\n  /// @param integrationAddress The address of the integration contract\n  /// @return The name of the of the protocol being integrated to\n  function getIntegrationName(address integrationAddress)\n    external\n    view\n    returns (string memory);\n\n  /// @return The address of the WETH token\n  function getWethTokenAddress() external view returns (address);\n\n  /// @return The address of the BIOS token\n  function getBiosTokenAddress() external view returns (address);\n\n  /// @param tokenId The ID of the token\n  /// @return The address of the token ERC20 contract\n  function getTokenAddress(uint256 tokenId) external view returns (address);\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  /// @return The index of the token in the tokens array\n  function getTokenId(address tokenAddress) external view returns (uint256);\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  /// @return The token BIOS reward weight\n  function getTokenBiosRewardWeight(address tokenAddress)\n    external\n    view\n    returns (uint256);\n\n  /// @return rewardWeightSum reward weight of depositable tokens\n  function getBiosRewardWeightSum()\n    external\n    view\n    returns (uint256 rewardWeightSum);\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  /// @return bool indicating whether depositing this token is currently enabled\n  function getTokenAcceptingDeposits(address tokenAddress)\n    external\n    view\n    returns (bool);\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  /// @return bool indicating whether withdrawing this token is currently enabled\n  function getTokenAcceptingWithdrawals(address tokenAddress)\n    external\n    view\n    returns (bool);\n\n  // @param tokenAddress The address of the token ERC20 contract\n  // @return bool indicating whether the token has been added\n  function getIsTokenAdded(address tokenAddress) external view returns (bool);\n\n  // @param integrationAddress The address of the integration contract\n  // @return bool indicating whether the integration has been added\n  function getIsIntegrationAdded(address tokenAddress)\n    external\n    view\n    returns (bool);\n\n  /// @notice get the length of supported tokens\n  /// @return The quantity of tokens added\n  function getTokenAddressesLength() external view returns (uint256);\n\n  /// @notice get the length of supported integrations\n  /// @return The quantity of integrations added\n  function getIntegrationAddressesLength() external view returns (uint256);\n\n  /// @param tokenAddress The address of the token ERC20 contract\n  /// @return The value that gets divided by the reserve ratio denominator\n  function getTokenReserveRatioNumerator(address tokenAddress)\n    external\n    view\n    returns (uint256);\n\n  /// @return The token reserve ratio denominator\n  function getReserveRatioDenominator() external view returns (uint32);\n}\n"
    },
    "contracts/interfaces/IKernel.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\ninterface IKernel {\n  /// @param account The address of the account to check if they are a manager\n  /// @return Bool indicating whether the account is a manger\n  function isManager(address account) external view returns (bool);\n\n  /// @param account The address of the account to check if they are an owner\n  /// @return Bool indicating whether the account is an owner\n  function isOwner(address account) external view returns (bool);\n}\n"
    },
    "contracts/interfaces/IModuleMap.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\nenum Modules {\n  Kernel, // 0\n  UserPositions, // 1\n  YieldManager, // 2\n  IntegrationMap, // 3\n  BiosRewards, // 4\n  EtherRewards, // 5\n  SushiSwapTrader, // 6\n  UniswapTrader, // 7\n  StrategyMap, // 8\n  StrategyManager // 9\n}\n\ninterface IModuleMap {\n  function getModuleAddress(Modules key) external view returns (address);\n}\n"
    },
    "contracts/interfaces/IUserPositions.sol": {
      "content": "// SPDX-License-Identifier: GPL-2.0\npragma solidity ^0.8.4;\n\ninterface IUserPositions {\n  /// @param biosRewardsDuration_ The duration in seconds for a BIOS rewards period to last\n  function setBiosRewardsDuration(uint32 biosRewardsDuration_) external;\n\n  /// @param sender The account seeding BIOS rewards\n  /// @param biosAmount The amount of BIOS to add to rewards\n  function seedBiosRewards(address sender, uint256 biosAmount) external;\n\n  /// @notice Sends all BIOS available in the Kernel to each token BIOS rewards pool based up configured weights\n  function increaseBiosRewards() external;\n\n  /// @notice User is allowed to deposit whitelisted tokens\n  /// @param depositor Address of the account depositing\n  /// @param tokens Array of token the token addresses\n  /// @param amounts Array of token amounts\n  /// @param ethAmount The amount of ETH sent with the deposit\n  function deposit(\n    address depositor,\n    address[] memory tokens,\n    uint256[] memory amounts,\n    uint256 ethAmount\n  ) external;\n\n  /// @notice User is allowed to withdraw tokens\n  /// @param recipient The address of the user withdrawing\n  /// @param tokens Array of token the token addresses\n  /// @param amounts Array of token amounts\n  /// @param withdrawWethAsEth Boolean indicating whether should receive WETH balance as ETH\n  function withdraw(\n    address recipient,\n    address[] memory tokens,\n    uint256[] memory amounts,\n    bool withdrawWethAsEth\n  ) external returns (uint256 ethWithdrawn);\n\n  /// @notice Allows a user to withdraw entire balances of the specified tokens and claim rewards\n  /// @param recipient The address of the user withdrawing tokens\n  /// @param tokens Array of token address that user is exiting positions from\n  /// @param withdrawWethAsEth Boolean indicating whether should receive WETH balance as ETH\n  /// @return tokenAmounts The amounts of each token being withdrawn\n  /// @return ethWithdrawn The amount of ETH being withdrawn\n  /// @return ethClaimed The amount of ETH being claimed from rewards\n  /// @return biosClaimed The amount of BIOS being claimed from rewards\n  function withdrawAllAndClaim(\n    address recipient,\n    address[] memory tokens,\n    bool withdrawWethAsEth\n  )\n    external\n    returns (\n      uint256[] memory tokenAmounts,\n      uint256 ethWithdrawn,\n      uint256 ethClaimed,\n      uint256 biosClaimed\n    );\n\n  /// @param user The address of the user claiming ETH rewards\n  function claimEthRewards(address user) external returns (uint256 ethClaimed);\n\n  /// @notice Allows users to claim their BIOS rewards for each token\n  /// @param recipient The address of the usuer claiming BIOS rewards\n  function claimBiosRewards(address recipient)\n    external\n    returns (uint256 biosClaimed);\n\n  /// @param asset Address of the ERC20 token contract\n  /// @return The total balance of the asset deposited in the system\n  function totalTokenBalance(address asset) external view returns (uint256);\n\n  /// @param asset Address of the ERC20 token contract\n  /// @param account Address of the user account\n  function userTokenBalance(address asset, address account)\n    external\n    view\n    returns (uint256);\n\n  /// @return The Bios Rewards Duration\n  function getBiosRewardsDuration() external view returns (uint32);\n\n  /// @notice Transfers tokens to the StrategyMap\n  /// @dev This is a ledger adjustment. The tokens remain in the kernel.\n  /// @param recipient  The user to transfer funds for\n  /// @param tokens  the tokens to be moved\n  /// @param amounts  the amounts of each token to move\n  function transferToStrategy(\n    address recipient,\n    address[] memory tokens,\n    uint256[] memory amounts\n  ) external;\n\n  /// @notice Transfers tokens from the StrategyMap\n  /// @dev This is a ledger adjustment. The tokens remain in the kernel.\n  /// @param recipient  The user to transfer funds for\n  /// @param tokens  the tokens to be moved\n  /// @param amounts  the amounts of each token to move\n  function transferFromStrategy(\n    address recipient,\n    address[] memory tokens,\n    uint256[] memory amounts\n  ) external;\n}\n"
    }
  }
}}