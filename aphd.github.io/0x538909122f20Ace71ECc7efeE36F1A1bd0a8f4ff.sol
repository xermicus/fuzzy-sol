{"BundleExecutorFL.sol":{"content":"//SPDX-License-Identifier: UNLICENSED\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"./FlashLoanReceiverBase.sol\";\nimport \"./Interfaces.sol\";\nimport \"./Libraries.sol\";\n\ninterface IWETH is IERC20 {\n    function deposit() external payable;\n    function withdraw(uint) external;\n}\n\ncontract FlashBotsMultiCallFL is FlashLoanReceiverBase {\n    using SafeMath for uint256;\n    address private immutable owner;\n    address private immutable executor;\n    IWETH private constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\n    address private constant ETH_address = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);\n\n    modifier onlyExecutor() {\n        require(msg.sender == executor);\n        _;\n    }\n\n    modifier onlyOwner() {\n        require(msg.sender == owner);\n        _;\n    }\n\n    constructor(address _executor, ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) public payable {\n        owner = msg.sender;\n        executor = _executor;\n        if (msg.value \u003e 0) {\n            WETH.deposit{value: msg.value}();\n        }\n    }\n\n    /**\n        This function is called after your contract has received the flash loaned amount\n     */\n    function executeOperation(\n        address[] calldata assets,\n        uint256[] calldata amounts,\n        uint256[] calldata premiums,\n        address initiator,\n        bytes calldata params\n    )\n        external\n        override\n        returns (bool)\n    {\n        uint amountOwing = amounts[0].add(premiums[0]);\n        uniswapWethFLParams(amounts[0], params, amountOwing);\n        WETH.approve(address(LENDING_POOL), amountOwing);\n\n        return true;\n    }\n\n    function flashloan(address borrowedTokenAddress, uint256 amountToBorrow, bytes memory _params) external onlyExecutor() {\n        address receiverAddress = address(this);\n\n        address[] memory assets = new address[](1);\n        assets[0] = borrowedTokenAddress;\n\n        uint256[] memory amounts = new uint256[](1);\n        amounts[0] = amountToBorrow;\n\n        uint256[] memory modes = new uint256[](1);\n        modes[0] = 0;\n\n        address onBehalfOf = address(this);\n        uint16 referralCode = 161;\n\n        LENDING_POOL.flashLoan(\n            receiverAddress,\n            assets,\n            amounts,\n            modes,\n            onBehalfOf,\n            _params,\n            referralCode\n        );\n    }\n\n    function uniswapWethFLParams(uint256 _amountToFirstMarket, bytes memory _params, uint256 totalAaveDebt) internal {\n        (uint256 _ethAmountToCoinbase, address[] memory _targets, bytes[] memory _payloads) = abi.decode(_params, (uint256, address[], bytes[]));\n        require(_targets.length == _payloads.length);\n\n        WETH.transfer(_targets[0], _amountToFirstMarket);\n        for (uint256 i = 0; i \u003c _targets.length; i++) {\n            (bool _success, bytes memory _response) = _targets[i].call(_payloads[i]);\n            require(_success); \n        }\n\n        uint256 _wethBalanceAfter = WETH.balanceOf(address(this));\n        require(_wethBalanceAfter \u003e totalAaveDebt + _ethAmountToCoinbase);\n\n        uint256 _ethBalance = address(this).balance;\n        if (_ethBalance \u003c _ethAmountToCoinbase) {\n            WETH.withdraw(_ethAmountToCoinbase - _ethBalance);\n        }\n        block.coinbase.transfer(_ethAmountToCoinbase);\n    }\n\n    function call(address payable _to, uint256 _value, bytes calldata _data) external onlyOwner payable returns (bytes memory) {\n        require(_to != address(0));\n        (bool _success, bytes memory _result) = _to.call{value: _value}(_data);\n        require(_success);\n        return _result;\n    }\n\n    function withdraw(address token) external onlyOwner {\n        if (token == ETH_address) {\n            uint256 bal = address(this).balance;\n            msg.sender.transfer(bal);\n        } else if (token != ETH_address) {\n            uint256 bal = IERC20(token).balanceOf(address(this));\n            IERC20(token).transfer(address(msg.sender), bal);\n        }\n    }\n\n    receive() external payable {\n    }\n}\n"},"FlashLoanReceiverBase.sol":{"content":"// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.6.12;\n\nimport \"./Interfaces.sol\";\nimport \"./Libraries.sol\";\n\nabstract contract FlashLoanReceiverBase is IFlashLoanReceiver {\n  using SafeERC20 for IERC20;\n  using SafeMath for uint256;\n\n  ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;\n  ILendingPool public immutable LENDING_POOL;\n\n  constructor(ILendingPoolAddressesProvider provider) public {\n    ADDRESSES_PROVIDER = provider;\n    LENDING_POOL = ILendingPool(provider.getLendingPool());\n  }\n}"},"Interfaces.sol":{"content":"// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"./Libraries.sol\";\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n  /**\n   * @dev Returns the amount of tokens in existence.\n   */\n  function totalSupply() external view returns (uint256);\n\n  /**\n   * @dev Returns the amount of tokens owned by `account`.\n   */\n  function balanceOf(address account) external view returns (uint256);\n\n  /**\n   * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transfer(address recipient, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Returns the remaining number of tokens that `spender` will be\n   * allowed to spend on behalf of `owner` through {transferFrom}. This is\n   * zero by default.\n   *\n   * This value changes when {approve} or {transferFrom} are called.\n   */\n  function allowance(address owner, address spender) external view returns (uint256);\n\n  /**\n   * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * IMPORTANT: Beware that changing an allowance with this method brings the risk\n   * that someone may use both the old and the new allowance by unfortunate\n   * transaction ordering. One possible solution to mitigate this race\n   * condition is to first reduce the spender\u0027s allowance to 0 and set the\n   * desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   *\n   * Emits an {Approval} event.\n   */\n  function approve(address spender, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Moves `amount` tokens from `sender` to `recipient` using the\n   * allowance mechanism. `amount` is then deducted from the caller\u0027s\n   * allowance.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transferFrom(\n    address sender,\n    address recipient,\n    uint256 amount\n  ) external returns (bool);\n\n  /**\n   * @dev Emitted when `value` tokens are moved from one account (`from`) to\n   * another (`to`).\n   *\n   * Note that `value` may be zero.\n   */\n  event Transfer(address indexed from, address indexed to, uint256 value);\n\n  /**\n   * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n   * a call to {approve}. `value` is the new allowance.\n   */\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n\ninterface IFlashLoanReceiver {\n  function executeOperation(\n    address[] calldata assets,\n    uint256[] calldata amounts,\n    uint256[] calldata premiums,\n    address initiator,\n    bytes calldata params\n  ) external returns (bool);\n}\n\n/**\n * @title LendingPoolAddressesProvider contract\n * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles\n * - Acting also as factory of proxies and admin of those, so with right to change its implementations\n * - Owned by the Aave Governance\n * @author Aave\n **/\ninterface ILendingPoolAddressesProvider {\n  event LendingPoolUpdated(address indexed newAddress);\n  event ConfigurationAdminUpdated(address indexed newAddress);\n  event EmergencyAdminUpdated(address indexed newAddress);\n  event LendingPoolConfiguratorUpdated(address indexed newAddress);\n  event LendingPoolCollateralManagerUpdated(address indexed newAddress);\n  event PriceOracleUpdated(address indexed newAddress);\n  event LendingRateOracleUpdated(address indexed newAddress);\n  event ProxyCreated(bytes32 id, address indexed newAddress);\n  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);\n\n  function setAddress(bytes32 id, address newAddress) external;\n\n  function setAddressAsProxy(bytes32 id, address impl) external;\n\n  function getAddress(bytes32 id) external view returns (address);\n\n  function getLendingPool() external view returns (address);\n\n  function setLendingPoolImpl(address pool) external;\n\n  function getLendingPoolConfigurator() external view returns (address);\n\n  function setLendingPoolConfiguratorImpl(address configurator) external;\n\n  function getLendingPoolCollateralManager() external view returns (address);\n\n  function setLendingPoolCollateralManager(address manager) external;\n\n  function getPoolAdmin() external view returns (address);\n\n  function setPoolAdmin(address admin) external;\n\n  function getEmergencyAdmin() external view returns (address);\n\n  function setEmergencyAdmin(address admin) external;\n\n  function getPriceOracle() external view returns (address);\n\n  function setPriceOracle(address priceOracle) external;\n\n  function getLendingRateOracle() external view returns (address);\n\n  function setLendingRateOracle(address lendingRateOracle) external;\n}\n\ninterface ILendingPool {\n  /**\n   * @dev Emitted on deposit()\n   * @param reserve The address of the underlying asset of the reserve\n   * @param user The address initiating the deposit\n   * @param onBehalfOf The beneficiary of the deposit, receiving the aTokens\n   * @param amount The amount deposited\n   * @param referral The referral code used\n   **/\n  event Deposit(\n    address indexed reserve,\n    address user,\n    address indexed onBehalfOf,\n    uint256 amount,\n    uint16 indexed referral\n  );\n\n  /**\n   * @dev Emitted on withdraw()\n   * @param reserve The address of the underlyng asset being withdrawn\n   * @param user The address initiating the withdrawal, owner of aTokens\n   * @param to Address that will receive the underlying\n   * @param amount The amount to be withdrawn\n   **/\n  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);\n\n  /**\n   * @dev Emitted on borrow() and flashLoan() when debt needs to be opened\n   * @param reserve The address of the underlying asset being borrowed\n   * @param user The address of the user initiating the borrow(), receiving the funds on borrow() or just\n   * initiator of the transaction on flashLoan()\n   * @param onBehalfOf The address that will be getting the debt\n   * @param amount The amount borrowed out\n   * @param borrowRateMode The rate mode: 1 for Stable, 2 for Variable\n   * @param borrowRate The numeric rate at which the user has borrowed\n   * @param referral The referral code used\n   **/\n  event Borrow(\n    address indexed reserve,\n    address user,\n    address indexed onBehalfOf,\n    uint256 amount,\n    uint256 borrowRateMode,\n    uint256 borrowRate,\n    uint16 indexed referral\n  );\n\n  /**\n   * @dev Emitted on repay()\n   * @param reserve The address of the underlying asset of the reserve\n   * @param user The beneficiary of the repayment, getting his debt reduced\n   * @param repayer The address of the user initiating the repay(), providing the funds\n   * @param amount The amount repaid\n   **/\n  event Repay(\n    address indexed reserve,\n    address indexed user,\n    address indexed repayer,\n    uint256 amount\n  );\n\n  /**\n   * @dev Emitted on swapBorrowRateMode()\n   * @param reserve The address of the underlying asset of the reserve\n   * @param user The address of the user swapping his rate mode\n   * @param rateMode The rate mode that the user wants to swap to\n   **/\n  event Swap(address indexed reserve, address indexed user, uint256 rateMode);\n\n  /**\n   * @dev Emitted on setUserUseReserveAsCollateral()\n   * @param reserve The address of the underlying asset of the reserve\n   * @param user The address of the user enabling the usage as collateral\n   **/\n  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);\n\n  /**\n   * @dev Emitted on setUserUseReserveAsCollateral()\n   * @param reserve The address of the underlying asset of the reserve\n   * @param user The address of the user enabling the usage as collateral\n   **/\n  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);\n\n  /**\n   * @dev Emitted on rebalanceStableBorrowRate()\n   * @param reserve The address of the underlying asset of the reserve\n   * @param user The address of the user for which the rebalance has been executed\n   **/\n  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);\n\n  /**\n   * @dev Emitted on flashLoan()\n   * @param target The address of the flash loan receiver contract\n   * @param initiator The address initiating the flash loan\n   * @param asset The address of the asset being flash borrowed\n   * @param amount The amount flash borrowed\n   * @param premium The fee flash borrowed\n   * @param referralCode The referral code used\n   **/\n  event FlashLoan(\n    address indexed target,\n    address indexed initiator,\n    address indexed asset,\n    uint256 amount,\n    uint256 premium,\n    uint16 referralCode\n  );\n\n  /**\n   * @dev Emitted when the pause is triggered.\n   */\n  event Paused();\n\n  /**\n   * @dev Emitted when the pause is lifted.\n   */\n  event Unpaused();\n\n  /**\n   * @dev Emitted when a borrower is liquidated. This event is emitted by the LendingPool via\n   * LendingPoolCollateral manager using a DELEGATECALL\n   * This allows to have the events in the generated ABI for LendingPool.\n   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation\n   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation\n   * @param user The address of the borrower getting liquidated\n   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover\n   * @param liquidatedCollateralAmount The amount of collateral received by the liiquidator\n   * @param liquidator The address of the liquidator\n   * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants\n   * to receive the underlying collateral asset directly\n   **/\n  event LiquidationCall(\n    address indexed collateralAsset,\n    address indexed debtAsset,\n    address indexed user,\n    uint256 debtToCover,\n    uint256 liquidatedCollateralAmount,\n    address liquidator,\n    bool receiveAToken\n  );\n\n  /**\n   * @dev Emitted when the state of a reserve is updated. NOTE: This event is actually declared\n   * in the ReserveLogic library and emitted in the updateInterestRates() function. Since the function is internal,\n   * the event will actually be fired by the LendingPool contract. The event is therefore replicated here so it\n   * gets added to the LendingPool ABI\n   * @param reserve The address of the underlying asset of the reserve\n   * @param liquidityRate The new liquidity rate\n   * @param stableBorrowRate The new stable borrow rate\n   * @param variableBorrowRate The new variable borrow rate\n   * @param liquidityIndex The new liquidity index\n   * @param variableBorrowIndex The new variable borrow index\n   **/\n  event ReserveDataUpdated(\n    address indexed reserve,\n    uint256 liquidityRate,\n    uint256 stableBorrowRate,\n    uint256 variableBorrowRate,\n    uint256 liquidityIndex,\n    uint256 variableBorrowIndex\n  );\n\n  /**\n   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.\n   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC\n   * @param asset The address of the underlying asset to deposit\n   * @param amount The amount to be deposited\n   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user\n   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens\n   *   is a different wallet\n   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.\n   *   0 if the action is executed directly by the user, without any middle-man\n   **/\n  function deposit(\n    address asset,\n    uint256 amount,\n    address onBehalfOf,\n    uint16 referralCode\n  ) external;\n\n  /**\n   * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned\n   * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC\n   * @param asset The address of the underlying asset to withdraw\n   * @param amount The underlying amount to be withdrawn\n   *   - Send the value type(uint256).max in order to withdraw the whole aToken balance\n   * @param to Address that will receive the underlying, same as msg.sender if the user\n   *   wants to receive it on his own wallet, or a different address if the beneficiary is a\n   *   different wallet\n   **/\n  function withdraw(\n    address asset,\n    uint256 amount,\n    address to\n  ) external;\n\n  /**\n   * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower\n   * already deposited enough collateral, or he was given enough allowance by a credit delegator on the\n   * corresponding debt token (StableDebtToken or VariableDebtToken)\n   * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet\n   *   and 100 stable/variable debt tokens, depending on the `interestRateMode`\n   * @param asset The address of the underlying asset to borrow\n   * @param amount The amount to be borrowed\n   * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable\n   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.\n   *   0 if the action is executed directly by the user, without any middle-man\n   * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself\n   * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator\n   * if he has been given credit delegation allowance\n   **/\n  function borrow(\n    address asset,\n    uint256 amount,\n    uint256 interestRateMode,\n    uint16 referralCode,\n    address onBehalfOf\n  ) external;\n\n  /**\n   * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned\n   * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address\n   * @param asset The address of the borrowed underlying asset previously borrowed\n   * @param amount The amount to repay\n   * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`\n   * @param rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable\n   * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the\n   * user calling the function if he wants to reduce/remove his own debt, or the address of any other\n   * other borrower whose debt should be removed\n   **/\n  function repay(\n    address asset,\n    uint256 amount,\n    uint256 rateMode,\n    address onBehalfOf\n  ) external;\n\n  /**\n   * @dev Allows a borrower to swap his debt between stable and variable mode, or viceversa\n   * @param asset The address of the underlying asset borrowed\n   * @param rateMode The rate mode that the user wants to swap to\n   **/\n  function swapBorrowRateMode(address asset, uint256 rateMode) external;\n\n  /**\n   * @dev Rebalances the stable interest rate of a user to the current stable rate defined on the reserve.\n   * - Users can be rebalanced if the following conditions are satisfied:\n   *     1. Usage ratio is above 95%\n   *     2. the current deposit APY is below REBALANCE_UP_THRESHOLD * maxVariableBorrowRate, which means that too much has been\n   *        borrowed at a stable rate and depositors are not earning enough\n   * @param asset The address of the underlying asset borrowed\n   * @param user The address of the user to be rebalanced\n   **/\n  function rebalanceStableBorrowRate(address asset, address user) external;\n\n  /**\n   * @dev Allows depositors to enable/disable a specific deposited asset as collateral\n   * @param asset The address of the underlying asset deposited\n   * @param useAsCollateral `true` if the user wants to use the deposit as collateral, `false` otherwise\n   **/\n  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;\n\n  /**\n   * @dev Function to liquidate a non-healthy position collateral-wise, with Health Factor below 1\n   * - The caller (liquidator) covers `debtToCover` amount of debt of the user getting liquidated, and receives\n   *   a proportionally amount of the `collateralAsset` plus a bonus to cover market risk\n   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation\n   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation\n   * @param user The address of the borrower getting liquidated\n   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover\n   * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants\n   * to receive the underlying collateral asset directly\n   **/\n  function liquidationCall(\n    address collateralAsset,\n    address debtAsset,\n    address user,\n    uint256 debtToCover,\n    bool receiveAToken\n  ) external;\n\n  /**\n   * @dev Allows smartcontracts to access the liquidity of the pool within one transaction,\n   * as long as the amount taken plus a fee is returned.\n   * IMPORTANT There are security concerns for developers of flashloan receiver contracts that must be kept into consideration.\n   * For further details please visit https://developers.aave.com\n   * @param receiverAddress The address of the contract receiving the funds, implementing the IFlashLoanReceiver interface\n   * @param assets The addresses of the assets being flash-borrowed\n   * @param amounts The amounts amounts being flash-borrowed\n   * @param modes Types of the debt to open if the flash loan is not returned:\n   *   0 -\u003e Don\u0027t open any debt, just revert if funds can\u0027t be transferred from the receiver\n   *   1 -\u003e Open debt at stable rate for the value of the amount flash-borrowed to the `onBehalfOf` address\n   *   2 -\u003e Open debt at variable rate for the value of the amount flash-borrowed to the `onBehalfOf` address\n   * @param onBehalfOf The address  that will receive the debt in the case of using on `modes` 1 or 2\n   * @param params Variadic packed params to pass to the receiver as extra information\n   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.\n   *   0 if the action is executed directly by the user, without any middle-man\n   **/\n  function flashLoan(\n    address receiverAddress,\n    address[] calldata assets,\n    uint256[] calldata amounts,\n    uint256[] calldata modes,\n    address onBehalfOf,\n    bytes calldata params,\n    uint16 referralCode\n  ) external;\n\n  /**\n   * @dev Returns the user account data across all the reserves\n   * @param user The address of the user\n   * @return totalCollateralETH the total collateral in ETH of the user\n   * @return totalDebtETH the total debt in ETH of the user\n   * @return availableBorrowsETH the borrowing power left of the user\n   * @return currentLiquidationThreshold the liquidation threshold of the user\n   * @return ltv the loan to value of the user\n   * @return healthFactor the current health factor of the user\n   **/\n  function getUserAccountData(address user)\n    external\n    view\n    returns (\n      uint256 totalCollateralETH,\n      uint256 totalDebtETH,\n      uint256 availableBorrowsETH,\n      uint256 currentLiquidationThreshold,\n      uint256 ltv,\n      uint256 healthFactor\n    );\n\n  function initReserve(\n    address reserve,\n    address aTokenAddress,\n    address stableDebtAddress,\n    address variableDebtAddress,\n    address interestRateStrategyAddress\n  ) external;\n\n  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)\n    external;\n\n  function setConfiguration(address reserve, uint256 configuration) external;\n\n  /**\n   * @dev Returns the configuration of the reserve\n   * @param asset The address of the underlying asset of the reserve\n   * @return The configuration of the reserve\n   **/\n  function getConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);\n\n  /**\n   * @dev Returns the configuration of the user across all the reserves\n   * @param user The user address\n   * @return The configuration of the user\n   **/\n  function getUserConfiguration(address user) external view returns (DataTypes.UserConfigurationMap memory);\n\n  /**\n   * @dev Returns the normalized income normalized income of the reserve\n   * @param asset The address of the underlying asset of the reserve\n   * @return The reserve\u0027s normalized income\n   */\n  function getReserveNormalizedIncome(address asset) external view returns (uint256);\n\n  /**\n   * @dev Returns the normalized variable debt per unit of asset\n   * @param asset The address of the underlying asset of the reserve\n   * @return The reserve normalized variable debt\n   */\n  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);\n\n  /**\n   * @dev Returns the state and configuration of the reserve\n   * @param asset The address of the underlying asset of the reserve\n   * @return The state of the reserve\n   **/\n  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);\n\n  function finalizeTransfer(\n    address asset,\n    address from,\n    address to,\n    uint256 amount,\n    uint256 balanceFromAfter,\n    uint256 balanceToBefore\n  ) external;\n\n  function getReservesList() external view returns (address[] memory);\n\n  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);\n\n  function setPause(bool val) external;\n\n  function paused() external view returns (bool);\n}\n"},"Libraries.sol":{"content":"// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"./Interfaces.sol\";\n\nlibrary SafeMath {\n  /**\n   * @dev Returns the addition of two unsigned integers, reverting on\n   * overflow.\n   *\n   * Counterpart to Solidity\u0027s `+` operator.\n   *\n   * Requirements:\n   * - Addition cannot overflow.\n   */\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\n    uint256 c = a + b;\n    require(c \u003e= a, \u0027SafeMath: addition overflow\u0027);\n\n    return c;\n  }\n\n  /**\n   * @dev Returns the subtraction of two unsigned integers, reverting on\n   * overflow (when the result is negative).\n   *\n   * Counterpart to Solidity\u0027s `-` operator.\n   *\n   * Requirements:\n   * - Subtraction cannot overflow.\n   */\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n    return sub(a, b, \u0027SafeMath: subtraction overflow\u0027);\n  }\n\n  /**\n   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n   * overflow (when the result is negative).\n   *\n   * Counterpart to Solidity\u0027s `-` operator.\n   *\n   * Requirements:\n   * - Subtraction cannot overflow.\n   */\n  function sub(\n    uint256 a,\n    uint256 b,\n    string memory errorMessage\n  ) internal pure returns (uint256) {\n    require(b \u003c= a, errorMessage);\n    uint256 c = a - b;\n\n    return c;\n  }\n\n  /**\n   * @dev Returns the multiplication of two unsigned integers, reverting on\n   * overflow.\n   *\n   * Counterpart to Solidity\u0027s `*` operator.\n   *\n   * Requirements:\n   * - Multiplication cannot overflow.\n   */\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n    // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n    // benefit is lost if \u0027b\u0027 is also tested.\n    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n    if (a == 0) {\n      return 0;\n    }\n\n    uint256 c = a * b;\n    require(c / a == b, \u0027SafeMath: multiplication overflow\u0027);\n\n    return c;\n  }\n\n  /**\n   * @dev Returns the integer division of two unsigned integers. Reverts on\n   * division by zero. The result is rounded towards zero.\n   *\n   * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n   * `revert` opcode (which leaves remaining gas untouched) while Solidity\n   * uses an invalid opcode to revert (consuming all remaining gas).\n   *\n   * Requirements:\n   * - The divisor cannot be zero.\n   */\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n    return div(a, b, \u0027SafeMath: division by zero\u0027);\n  }\n\n  /**\n   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n   * division by zero. The result is rounded towards zero.\n   *\n   * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n   * `revert` opcode (which leaves remaining gas untouched) while Solidity\n   * uses an invalid opcode to revert (consuming all remaining gas).\n   *\n   * Requirements:\n   * - The divisor cannot be zero.\n   */\n  function div(\n    uint256 a,\n    uint256 b,\n    string memory errorMessage\n  ) internal pure returns (uint256) {\n    // Solidity only automatically asserts when dividing by 0\n    require(b \u003e 0, errorMessage);\n    uint256 c = a / b;\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n    return c;\n  }\n\n  /**\n   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n   * Reverts when dividing by zero.\n   *\n   * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n   * opcode (which leaves remaining gas untouched) while Solidity uses an\n   * invalid opcode to revert (consuming all remaining gas).\n   *\n   * Requirements:\n   * - The divisor cannot be zero.\n   */\n  function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n    return mod(a, b, \u0027SafeMath: modulo by zero\u0027);\n  }\n\n  /**\n   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n   * Reverts with custom message when dividing by zero.\n   *\n   * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n   * opcode (which leaves remaining gas untouched) while Solidity uses an\n   * invalid opcode to revert (consuming all remaining gas).\n   *\n   * Requirements:\n   * - The divisor cannot be zero.\n   */\n  function mod(\n    uint256 a,\n    uint256 b,\n    string memory errorMessage\n  ) internal pure returns (uint256) {\n    require(b != 0, errorMessage);\n    return a % b;\n  }\n}\n\nlibrary Address {\n  /**\n   * @dev Returns true if `account` is a contract.\n   *\n   * [IMPORTANT]\n   * ====\n   * It is unsafe to assume that an address for which this function returns\n   * false is an externally-owned account (EOA) and not a contract.\n   *\n   * Among others, `isContract` will return false for the following\n   * types of addresses:\n   *\n   *  - an externally-owned account\n   *  - a contract in construction\n   *  - an address where a contract will be created\n   *  - an address where a contract lived, but was destroyed\n   * ====\n   */\n  function isContract(address account) internal view returns (bool) {\n    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\n    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\n    // for accounts without code, i.e. `keccak256(\u0027\u0027)`\n    bytes32 codehash;\n    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\n    // solhint-disable-next-line no-inline-assembly\n    assembly {\n      codehash := extcodehash(account)\n    }\n    return (codehash != accountHash \u0026\u0026 codehash != 0x0);\n  }\n\n  /**\n   * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\n   * `recipient`, forwarding all available gas and reverting on errors.\n   *\n   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n   * of certain opcodes, possibly making contracts go over the 2300 gas limit\n   * imposed by `transfer`, making them unable to receive funds via\n   * `transfer`. {sendValue} removes this limitation.\n   *\n   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n   *\n   * IMPORTANT: because control is transferred to `recipient`, care must be\n   * taken to not create reentrancy vulnerabilities. Consider using\n   * {ReentrancyGuard} or the\n   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n   */\n  function sendValue(address payable recipient, uint256 amount) internal {\n    require(address(this).balance \u003e= amount, \u0027Address: insufficient balance\u0027);\n\n    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\n    (bool success, ) = recipient.call{value: amount}(\u0027\u0027);\n    require(success, \u0027Address: unable to send value, recipient may have reverted\u0027);\n  }\n}\n\n\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n  using SafeMath for uint256;\n  using Address for address;\n\n  function safeTransfer(\n    IERC20 token,\n    address to,\n    uint256 value\n  ) internal {\n    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n  }\n\n  function safeTransferFrom(\n    IERC20 token,\n    address from,\n    address to,\n    uint256 value\n  ) internal {\n    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n  }\n\n  function safeApprove(\n    IERC20 token,\n    address spender,\n    uint256 value\n  ) internal {\n    require(\n      (value == 0) || (token.allowance(address(this), spender) == 0),\n      \u0027SafeERC20: approve from non-zero to non-zero allowance\u0027\n    );\n    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n  }\n\n  function callOptionalReturn(IERC20 token, bytes memory data) private {\n    require(address(token).isContract(), \u0027SafeERC20: call to non-contract\u0027);\n\n    // solhint-disable-next-line avoid-low-level-calls\n    (bool success, bytes memory returndata) = address(token).call(data);\n    require(success, \u0027SafeERC20: low-level call failed\u0027);\n\n    if (returndata.length \u003e 0) {\n      // Return data is optional\n      // solhint-disable-next-line max-line-length\n      require(abi.decode(returndata, (bool)), \u0027SafeERC20: ERC20 operation did not succeed\u0027);\n    }\n  }\n}\n\nlibrary DataTypes {\n  // refer to the whitepaper, section 1.1 basic concepts for a formal description of these properties.\n  struct ReserveData {\n    //stores the reserve configuration\n    ReserveConfigurationMap configuration;\n    //the liquidity index. Expressed in ray\n    uint128 liquidityIndex;\n    //variable borrow index. Expressed in ray\n    uint128 variableBorrowIndex;\n    //the current supply rate. Expressed in ray\n    uint128 currentLiquidityRate;\n    //the current variable borrow rate. Expressed in ray\n    uint128 currentVariableBorrowRate;\n    //the current stable borrow rate. Expressed in ray\n    uint128 currentStableBorrowRate;\n    uint40 lastUpdateTimestamp;\n    //tokens addresses\n    address aTokenAddress;\n    address stableDebtTokenAddress;\n    address variableDebtTokenAddress;\n    //address of the interest rate strategy\n    address interestRateStrategyAddress;\n    //the id of the reserve. Represents the position in the list of the active reserves\n    uint8 id;\n  }\n\n  struct ReserveConfigurationMap {\n    //bit 0-15: LTV\n    //bit 16-31: Liq. threshold\n    //bit 32-47: Liq. bonus\n    //bit 48-55: Decimals\n    //bit 56: Reserve is active\n    //bit 57: reserve is frozen\n    //bit 58: borrowing is enabled\n    //bit 59: stable rate borrowing enabled\n    //bit 60-63: reserved\n    //bit 64-79: reserve factor\n    uint256 data;\n  }\n\n  struct UserConfigurationMap {\n    uint256 data;\n  }\n\n  enum InterestRateMode {NONE, STABLE, VARIABLE}\n}\n"}}