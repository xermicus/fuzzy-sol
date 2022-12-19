{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 1000000
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
    "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20Upgradeable {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/utils/introspection/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "contracts/interfaces/IAccessControl.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\n/// @title IAccessControl\n/// @author Forked from OpenZeppelin\n/// @notice Interface for `AccessControl` contracts\ninterface IAccessControl {\n    function hasRole(bytes32 role, address account) external view returns (bool);\n\n    function getRoleAdmin(bytes32 role) external view returns (bytes32);\n\n    function grantRole(bytes32 role, address account) external;\n\n    function revokeRole(bytes32 role, address account) external;\n\n    function renounceRole(bytes32 role, address account) external;\n}\n"
    },
    "contracts/interfaces/IERC721.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"@openzeppelin/contracts/utils/introspection/IERC165.sol\";\n\ninterface IERC721 is IERC165 {\n    function balanceOf(address owner) external view returns (uint256 balance);\n\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 tokenId\n    ) external;\n\n    function approve(address to, uint256 tokenId) external;\n\n    function getApproved(uint256 tokenId) external view returns (address operator);\n\n    function setApprovalForAll(address operator, bool _approved) external;\n\n    function isApprovedForAll(address owner, address operator) external view returns (bool);\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 tokenId,\n        bytes calldata data\n    ) external;\n}\n\ninterface IERC721Metadata is IERC721 {\n    function name() external view returns (string memory);\n\n    function symbol() external view returns (string memory);\n\n    function tokenURI(uint256 tokenId) external view returns (string memory);\n}\n"
    },
    "contracts/interfaces/IFeeManager.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"./IAccessControl.sol\";\n\n/// @title IFeeManagerFunctions\n/// @author Angle Core Team\n/// @dev Interface for the `FeeManager` contract\ninterface IFeeManagerFunctions is IAccessControl {\n    // ================================= Keepers ===================================\n\n    function updateUsersSLP() external;\n\n    function updateHA() external;\n\n    // ================================= Governance ================================\n\n    function deployCollateral(\n        address[] memory governorList,\n        address guardian,\n        address _perpetualManager\n    ) external;\n\n    function setFees(\n        uint256[] memory xArray,\n        uint64[] memory yArray,\n        uint8 typeChange\n    ) external;\n\n    function setHAFees(uint64 _haFeeDeposit, uint64 _haFeeWithdraw) external;\n}\n\n/// @title IFeeManager\n/// @author Angle Core Team\n/// @notice Previous interface with additionnal getters for public variables and mappings\n/// @dev We need these getters as they are used in other contracts of the protocol\ninterface IFeeManager is IFeeManagerFunctions {\n    function stableMaster() external view returns (address);\n\n    function perpetualManager() external view returns (address);\n}\n"
    },
    "contracts/interfaces/IOracle.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\n/// @title IOracle\n/// @author Angle Core Team\n/// @notice Interface for Angle's oracle contracts reading oracle rates from both UniswapV3 and Chainlink\n/// from just UniswapV3 or from just Chainlink\ninterface IOracle {\n    function read() external view returns (uint256);\n\n    function readAll() external view returns (uint256 lowerRate, uint256 upperRate);\n\n    function readLower() external view returns (uint256);\n\n    function readUpper() external view returns (uint256);\n\n    function readQuote(uint256 baseAmount) external view returns (uint256);\n\n    function readQuoteLower(uint256 baseAmount) external view returns (uint256);\n\n    function inBase() external view returns (uint256);\n}\n"
    },
    "contracts/interfaces/IPerpetualManager.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"./IERC721.sol\";\nimport \"./IFeeManager.sol\";\nimport \"./IOracle.sol\";\nimport \"./IAccessControl.sol\";\n\n/// @title Interface of the contract managing perpetuals\n/// @author Angle Core Team\n/// @dev Front interface, meaning only user-facing functions\ninterface IPerpetualManagerFront is IERC721Metadata {\n    function openPerpetual(\n        address owner,\n        uint256 amountBrought,\n        uint256 amountCommitted,\n        uint256 maxOracleRate,\n        uint256 minNetMargin\n    ) external returns (uint256 perpetualID);\n\n    function closePerpetual(\n        uint256 perpetualID,\n        address to,\n        uint256 minCashOutAmount\n    ) external;\n\n    function addToPerpetual(uint256 perpetualID, uint256 amount) external;\n\n    function removeFromPerpetual(\n        uint256 perpetualID,\n        uint256 amount,\n        address to\n    ) external;\n\n    function liquidatePerpetuals(uint256[] memory perpetualIDs) external;\n\n    function forceClosePerpetuals(uint256[] memory perpetualIDs) external;\n\n    // ========================= External View Functions =============================\n\n    function getCashOutAmount(uint256 perpetualID, uint256 rate) external view returns (uint256, uint256);\n\n    function isApprovedOrOwner(address spender, uint256 perpetualID) external view returns (bool);\n}\n\n/// @title Interface of the contract managing perpetuals\n/// @author Angle Core Team\n/// @dev This interface does not contain user facing functions, it just has functions that are\n/// interacted with in other parts of the protocol\ninterface IPerpetualManagerFunctions is IAccessControl {\n    // ================================= Governance ================================\n\n    function deployCollateral(\n        address[] memory governorList,\n        address guardian,\n        IFeeManager feeManager,\n        IOracle oracle_\n    ) external;\n\n    function setFeeManager(IFeeManager feeManager_) external;\n\n    function setHAFees(\n        uint64[] memory _xHAFees,\n        uint64[] memory _yHAFees,\n        uint8 deposit\n    ) external;\n\n    function setTargetAndLimitHAHedge(uint64 _targetHAHedge, uint64 _limitHAHedge) external;\n\n    function setKeeperFeesLiquidationRatio(uint64 _keeperFeesLiquidationRatio) external;\n\n    function setKeeperFeesCap(uint256 _keeperFeesLiquidationCap, uint256 _keeperFeesClosingCap) external;\n\n    function setKeeperFeesClosing(uint64[] memory _xKeeperFeesClosing, uint64[] memory _yKeeperFeesClosing) external;\n\n    function setLockTime(uint64 _lockTime) external;\n\n    function setBoundsPerpetual(uint64 _maxLeverage, uint64 _maintenanceMargin) external;\n\n    function pause() external;\n\n    function unpause() external;\n\n    // ==================================== Keepers ================================\n\n    function setFeeKeeper(uint64 feeDeposit, uint64 feesWithdraw) external;\n\n    // =============================== StableMaster ================================\n\n    function setOracle(IOracle _oracle) external;\n}\n\n/// @title IPerpetualManager\n/// @author Angle Core Team\n/// @notice Previous interface with additionnal getters for public variables\ninterface IPerpetualManager is IPerpetualManagerFunctions {\n    function poolManager() external view returns (address);\n\n    function oracle() external view returns (address);\n\n    function targetHAHedge() external view returns (uint64);\n\n    function totalHedgeAmount() external view returns (uint256);\n}\n"
    },
    "contracts/interfaces/IPoolManager.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"./IFeeManager.sol\";\nimport \"./IPerpetualManager.sol\";\nimport \"./IOracle.sol\";\n\n// Struct for the parameters associated to a strategy interacting with a collateral `PoolManager`\n// contract\nstruct StrategyParams {\n    // Timestamp of last report made by this strategy\n    // It is also used to check if a strategy has been initialized\n    uint256 lastReport;\n    // Total amount the strategy is expected to have\n    uint256 totalStrategyDebt;\n    // The share of the total assets in the `PoolManager` contract that the `strategy` can access to.\n    uint256 debtRatio;\n}\n\n/// @title IPoolManagerFunctions\n/// @author Angle Core Team\n/// @notice Interface for the collateral poolManager contracts handling each one type of collateral for\n/// a given stablecoin\n/// @dev Only the functions used in other contracts of the protocol are left here\ninterface IPoolManagerFunctions {\n    // ============================ Constructor ====================================\n\n    function deployCollateral(\n        address[] memory governorList,\n        address guardian,\n        IPerpetualManager _perpetualManager,\n        IFeeManager feeManager,\n        IOracle oracle\n    ) external;\n\n    // ============================ Yield Farming ==================================\n\n    function creditAvailable() external view returns (uint256);\n\n    function debtOutstanding() external view returns (uint256);\n\n    function report(\n        uint256 _gain,\n        uint256 _loss,\n        uint256 _debtPayment\n    ) external;\n\n    // ============================ Governance =====================================\n\n    function addGovernor(address _governor) external;\n\n    function removeGovernor(address _governor) external;\n\n    function setGuardian(address _guardian, address guardian) external;\n\n    function revokeGuardian(address guardian) external;\n\n    function setFeeManager(IFeeManager _feeManager) external;\n\n    // ============================= Getters =======================================\n\n    function getBalance() external view returns (uint256);\n\n    function getTotalAsset() external view returns (uint256);\n}\n\n/// @title IPoolManager\n/// @author Angle Core Team\n/// @notice Previous interface with additionnal getters for public variables and mappings\n/// @dev Used in other contracts of the protocol\ninterface IPoolManager is IPoolManagerFunctions {\n    function stableMaster() external view returns (address);\n\n    function perpetualManager() external view returns (address);\n\n    function token() external view returns (address);\n\n    function feeManager() external view returns (address);\n\n    function totalDebt() external view returns (uint256);\n\n    function strategies(address _strategy) external view returns (StrategyParams memory);\n}\n"
    },
    "contracts/interfaces/ISanToken.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol\";\n\n/// @title ISanToken\n/// @author Angle Core Team\n/// @notice Interface for Angle's `SanToken` contract that handles sanTokens, tokens that are given to SLPs\n/// contributing to a collateral for a given stablecoin\ninterface ISanToken is IERC20Upgradeable {\n    // ================================== StableMaster =============================\n\n    function mint(address account, uint256 amount) external;\n\n    function burnFrom(\n        uint256 amount,\n        address burner,\n        address sender\n    ) external;\n\n    function burnSelf(uint256 amount, address burner) external;\n\n    function stableMaster() external view returns (address);\n\n    function poolManager() external view returns (address);\n}\n"
    },
    "contracts/interfaces/IStableMaster.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\n// Normally just importing `IPoolManager` should be sufficient, but for clarity here\n// we prefer to import all concerned interfaces\nimport \"./IPoolManager.sol\";\nimport \"./IOracle.sol\";\nimport \"./IPerpetualManager.sol\";\nimport \"./ISanToken.sol\";\n\n// Struct to handle all the parameters to manage the fees\n// related to a given collateral pool (associated to the stablecoin)\nstruct MintBurnData {\n    // Values of the thresholds to compute the minting fees\n    // depending on HA hedge (scaled by `BASE_PARAMS`)\n    uint64[] xFeeMint;\n    // Values of the fees at thresholds (scaled by `BASE_PARAMS`)\n    uint64[] yFeeMint;\n    // Values of the thresholds to compute the burning fees\n    // depending on HA hedge (scaled by `BASE_PARAMS`)\n    uint64[] xFeeBurn;\n    // Values of the fees at thresholds (scaled by `BASE_PARAMS`)\n    uint64[] yFeeBurn;\n    // Max proportion of collateral from users that can be covered by HAs\n    // It is exactly the same as the parameter of the same name in `PerpetualManager`, whenever one is updated\n    // the other changes accordingly\n    uint64 targetHAHedge;\n    // Minting fees correction set by the `FeeManager` contract: they are going to be multiplied\n    // to the value of the fees computed using the hedge curve\n    // Scaled by `BASE_PARAMS`\n    uint64 bonusMalusMint;\n    // Burning fees correction set by the `FeeManager` contract: they are going to be multiplied\n    // to the value of the fees computed using the hedge curve\n    // Scaled by `BASE_PARAMS`\n    uint64 bonusMalusBurn;\n    // Parameter used to limit the number of stablecoins that can be issued using the concerned collateral\n    uint256 capOnStableMinted;\n}\n\n// Struct to handle all the variables and parameters to handle SLPs in the protocol\n// including the fraction of interests they receive or the fees to be distributed to\n// them\nstruct SLPData {\n    // Last timestamp at which the `sanRate` has been updated for SLPs\n    uint256 lastBlockUpdated;\n    // Fees accumulated from previous blocks and to be distributed to SLPs\n    uint256 lockedInterests;\n    // Max interests used to update the `sanRate` in a single block\n    // Should be in collateral token base\n    uint256 maxInterestsDistributed;\n    // Amount of fees left aside for SLPs and that will be distributed\n    // when the protocol is collateralized back again\n    uint256 feesAside;\n    // Part of the fees normally going to SLPs that is left aside\n    // before the protocol is collateralized back again (depends on collateral ratio)\n    // Updated by keepers and scaled by `BASE_PARAMS`\n    uint64 slippageFee;\n    // Portion of the fees from users minting and burning\n    // that goes to SLPs (the rest goes to surplus)\n    uint64 feesForSLPs;\n    // Slippage factor that's applied to SLPs exiting (depends on collateral ratio)\n    // If `slippage = BASE_PARAMS`, SLPs can get nothing, if `slippage = 0` they get their full claim\n    // Updated by keepers and scaled by `BASE_PARAMS`\n    uint64 slippage;\n    // Portion of the interests from lending\n    // that goes to SLPs (the rest goes to surplus)\n    uint64 interestsForSLPs;\n}\n\n/// @title IStableMasterFunctions\n/// @author Angle Core Team\n/// @notice Interface for the `StableMaster` contract\ninterface IStableMasterFunctions {\n    function deploy(\n        address[] memory _governorList,\n        address _guardian,\n        address _agToken\n    ) external;\n\n    // ============================== Lending ======================================\n\n    function accumulateInterest(uint256 gain) external;\n\n    function signalLoss(uint256 loss) external;\n\n    // ============================== HAs ==========================================\n\n    function getStocksUsers() external view returns (uint256 maxCAmountInStable);\n\n    function convertToSLP(uint256 amount, address user) external;\n\n    // ============================== Keepers ======================================\n\n    function getCollateralRatio() external returns (uint256);\n\n    function setFeeKeeper(\n        uint64 feeMint,\n        uint64 feeBurn,\n        uint64 _slippage,\n        uint64 _slippageFee\n    ) external;\n\n    // ============================== AgToken ======================================\n\n    function updateStocksUsers(uint256 amount, address poolManager) external;\n\n    // ============================= Governance ====================================\n\n    function setCore(address newCore) external;\n\n    function addGovernor(address _governor) external;\n\n    function removeGovernor(address _governor) external;\n\n    function setGuardian(address newGuardian, address oldGuardian) external;\n\n    function revokeGuardian(address oldGuardian) external;\n\n    function setCapOnStableAndMaxInterests(\n        uint256 _capOnStableMinted,\n        uint256 _maxInterestsDistributed,\n        IPoolManager poolManager\n    ) external;\n\n    function setIncentivesForSLPs(\n        uint64 _feesForSLPs,\n        uint64 _interestsForSLPs,\n        IPoolManager poolManager\n    ) external;\n\n    function setUserFees(\n        IPoolManager poolManager,\n        uint64[] memory _xFee,\n        uint64[] memory _yFee,\n        uint8 _mint\n    ) external;\n\n    function setTargetHAHedge(uint64 _targetHAHedge) external;\n\n    function pause(bytes32 agent, IPoolManager poolManager) external;\n\n    function unpause(bytes32 agent, IPoolManager poolManager) external;\n}\n\n/// @title IStableMaster\n/// @author Angle Core Team\n/// @notice Previous interface with additionnal getters for public variables and mappings\ninterface IStableMaster is IStableMasterFunctions {\n    function agToken() external view returns (address);\n\n    function collateralMap(IPoolManager poolManager)\n        external\n        view\n        returns (\n            IERC20 token,\n            ISanToken sanToken,\n            IPerpetualManager perpetualManager,\n            IOracle oracle,\n            uint256 stocksUsers,\n            uint256 sanRate,\n            uint256 collatBase,\n            SLPData memory slpData,\n            MintBurnData memory feeData\n        );\n}\n"
    },
    "contracts/orchestrator/Orchestrator.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\nimport \"../interfaces/IStableMaster.sol\";\n\npragma solidity ^0.8.7;\n\nstruct PoolParameters {\n    uint64[] xFeeMint;\n    uint64[] yFeeMint;\n    uint64[] xFeeBurn;\n    uint64[] yFeeBurn;\n    uint64[] xHAFeesDeposit;\n    uint64[] yHAFeesDeposit;\n    uint64[] xHAFeesWithdraw;\n    uint64[] yHAFeesWithdraw;\n    uint256[] xSlippageFee;\n    uint64[] ySlippageFee;\n    uint256[] xSlippage;\n    uint64[] ySlippage;\n    uint256[] xBonusMalusMint;\n    uint64[] yBonusMalusMint;\n    uint256[] xBonusMalusBurn;\n    uint64[] yBonusMalusBurn;\n    uint64[] xKeeperFeesClosing;\n    uint64[] yKeeperFeesClosing;\n    uint64 haFeeDeposit;\n    uint64 haFeeWithdraw;\n    uint256 capOnStableMinted;\n    uint256 maxInterestsDistributed;\n    uint64 feesForSLPs;\n    uint64 interestsForSLPs;\n    uint64 targetHAHedge;\n    uint64 limitHAHedge;\n    uint64 maxLeverage;\n    uint64 maintenanceMargin;\n    uint64 lockTime;\n    uint64 keeperFeesLiquidationRatio;\n    uint256 keeperFeesLiquidationCap;\n    uint256 keeperFeesClosingCap;\n}\n\n/// @title Orchestrator\n/// @author Angle Core Team\n/// @notice Contract that is used to facilitate the deployment of a given collateral on mainnet\ncontract Orchestrator {\n    /// @notice Deployer address that is allowed to call the `initCollateral` function\n    address public owner;\n\n    /// @notice Initializes the `owner`\n    constructor() {\n        owner = msg.sender;\n    }\n\n    /// @notice Initializes a pool\n    /// @param p List of all the parameters with which to initialize the pool\n    /// @dev Only the `owner` can call this function\n    function initCollateral(\n        IStableMaster stableMaster,\n        IPoolManager poolManager,\n        IPerpetualManager perpetualManager,\n        IFeeManager feeManager,\n        PoolParameters memory p\n    ) external {\n        require(msg.sender == owner, \"79\");\n        stableMaster.setUserFees(poolManager, p.xFeeMint, p.yFeeMint, 1);\n        stableMaster.setUserFees(poolManager, p.xFeeBurn, p.yFeeBurn, 0);\n\n        perpetualManager.setHAFees(p.xHAFeesDeposit, p.yHAFeesDeposit, 1);\n        perpetualManager.setHAFees(p.xHAFeesWithdraw, p.yHAFeesWithdraw, 0);\n\n        feeManager.setFees(p.xSlippageFee, p.ySlippageFee, 0);\n        feeManager.setFees(p.xBonusMalusMint, p.yBonusMalusMint, 1);\n        feeManager.setFees(p.xBonusMalusBurn, p.yBonusMalusBurn, 2);\n        feeManager.setFees(p.xSlippage, p.ySlippage, 3);\n\n        feeManager.setHAFees(p.haFeeDeposit, p.haFeeWithdraw);\n\n        stableMaster.setCapOnStableAndMaxInterests(p.capOnStableMinted, p.maxInterestsDistributed, poolManager);\n        stableMaster.setIncentivesForSLPs(p.feesForSLPs, p.interestsForSLPs, poolManager);\n\n        perpetualManager.setTargetAndLimitHAHedge(p.targetHAHedge, p.limitHAHedge);\n        perpetualManager.setBoundsPerpetual(p.maxLeverage, p.maintenanceMargin);\n        perpetualManager.setLockTime(p.lockTime);\n        perpetualManager.setKeeperFeesLiquidationRatio(p.keeperFeesLiquidationRatio);\n        perpetualManager.setKeeperFeesCap(p.keeperFeesLiquidationCap, p.keeperFeesClosingCap);\n        perpetualManager.setKeeperFeesClosing(p.xKeeperFeesClosing, p.yKeeperFeesClosing);\n\n        feeManager.updateHA();\n        feeManager.updateUsersSLP();\n        /*\n        stableMaster.unpause(keccak256(\"STABLE\"), poolManager);\n        stableMaster.unpause(keccak256(\"SLP\"), poolManager);\n        perpetualManager.unpause();\n        */\n    }\n}\n"
    }
  }
}}