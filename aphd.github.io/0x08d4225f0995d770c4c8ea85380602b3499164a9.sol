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
      "details": {
        "constantOptimizer": true,
        "cse": true,
        "deduplicate": true,
        "jumpdestRemover": true,
        "orderLiterals": true,
        "peephole": true,
        "yul": false
      },
      "runs": 200
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
    "@openzeppelin/contracts/math/SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it's recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        uint256 c = a + b;\n        if (c < a) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b > a) return (false, 0);\n        return (true, a - b);\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) return (true, 0);\n        uint256 c = a * b;\n        if (c / a != b) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a / b);\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a % b);\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b <= a, \"SafeMath: subtraction overflow\");\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) return 0;\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryDiv}.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a % b;\n    }\n}\n"
    },
    "contracts/release/core/fund-deployer/IFundDeployer.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\n/// @title IFundDeployer Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IFundDeployer {\n    enum ReleaseStatus {PreLaunch, Live, Paused}\n\n    function getOwner() external view returns (address);\n\n    function getReleaseStatus() external view returns (ReleaseStatus);\n\n    function isRegisteredVaultCall(address, bytes4) external view returns (bool);\n}\n"
    },
    "contracts/release/extensions/policy-manager/IPolicy.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"./IPolicyManager.sol\";\n\n/// @title Policy Interface\n/// @author Enzyme Council <security@enzyme.finance>\ninterface IPolicy {\n    function activateForFund(address _comptrollerProxy, address _vaultProxy) external;\n\n    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings) external;\n\n    function identifier() external pure returns (string memory identifier_);\n\n    function implementedHooks()\n        external\n        view\n        returns (IPolicyManager.PolicyHook[] memory implementedHooks_);\n\n    function updateFundSettings(\n        address _comptrollerProxy,\n        address _vaultProxy,\n        bytes calldata _encodedSettings\n    ) external;\n\n    function validateRule(\n        address _comptrollerProxy,\n        address _vaultProxy,\n        IPolicyManager.PolicyHook _hook,\n        bytes calldata _encodedArgs\n    ) external returns (bool isValid_);\n}\n"
    },
    "contracts/release/extensions/policy-manager/IPolicyManager.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\n/// @title PolicyManager Interface\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Interface for the PolicyManager\ninterface IPolicyManager {\n    enum PolicyHook {\n        BuySharesSetup,\n        PreBuyShares,\n        PostBuyShares,\n        BuySharesCompleted,\n        PreCallOnIntegration,\n        PostCallOnIntegration\n    }\n\n    function validatePolicies(\n        address,\n        PolicyHook,\n        bytes calldata\n    ) external;\n}\n"
    },
    "contracts/release/extensions/policy-manager/policies/call-on-integration/GuaranteedRedemption.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"@openzeppelin/contracts/math/SafeMath.sol\";\nimport \"../../../utils/FundDeployerOwnerMixin.sol\";\nimport \"./utils/PreCallOnIntegrationValidatePolicyBase.sol\";\n\n/// @title GuaranteedRedemption Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A policy that guarantees that shares will either be continuously redeemable or\n/// redeemable within a predictable daily window by preventing trading during a configurable daily period\ncontract GuaranteedRedemption is PreCallOnIntegrationValidatePolicyBase, FundDeployerOwnerMixin {\n    using SafeMath for uint256;\n\n    event AdapterAdded(address adapter);\n\n    event AdapterRemoved(address adapter);\n\n    event FundSettingsSet(\n        address indexed comptrollerProxy,\n        uint256 startTimestamp,\n        uint256 duration\n    );\n\n    event RedemptionWindowBufferSet(uint256 prevBuffer, uint256 nextBuffer);\n\n    struct RedemptionWindow {\n        uint256 startTimestamp;\n        uint256 duration;\n    }\n\n    uint256 private constant ONE_DAY = 24 * 60 * 60;\n\n    mapping(address => bool) private adapterToCanBlockRedemption;\n    mapping(address => RedemptionWindow) private comptrollerProxyToRedemptionWindow;\n    uint256 private redemptionWindowBuffer;\n\n    constructor(\n        address _policyManager,\n        address _fundDeployer,\n        uint256 _redemptionWindowBuffer,\n        address[] memory _redemptionBlockingAdapters\n    ) public PolicyBase(_policyManager) FundDeployerOwnerMixin(_fundDeployer) {\n        redemptionWindowBuffer = _redemptionWindowBuffer;\n\n        __addRedemptionBlockingAdapters(_redemptionBlockingAdapters);\n    }\n\n    // EXTERNAL FUNCTIONS\n\n    /// @notice Add the initial policy settings for a fund\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _encodedSettings Encoded settings to apply to a fund\n    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)\n        external\n        override\n        onlyPolicyManager\n    {\n        (uint256 startTimestamp, uint256 duration) = abi.decode(\n            _encodedSettings,\n            (uint256, uint256)\n        );\n\n        if (startTimestamp == 0) {\n            require(duration == 0, \"addFundSettings: duration must be 0 if startTimestamp is 0\");\n            return;\n        }\n\n        // Use 23 hours instead of 1 day to allow up to 1 hr of redemptionWindowBuffer\n        require(\n            duration > 0 && duration <= 23 hours,\n            \"addFundSettings: duration must be between 1 second and 23 hours\"\n        );\n\n        comptrollerProxyToRedemptionWindow[_comptrollerProxy].startTimestamp = startTimestamp;\n        comptrollerProxyToRedemptionWindow[_comptrollerProxy].duration = duration;\n\n        emit FundSettingsSet(_comptrollerProxy, startTimestamp, duration);\n    }\n\n    /// @notice Provides a constant string identifier for a policy\n    /// @return identifier_ The identifer string\n    function identifier() external pure override returns (string memory identifier_) {\n        return \"GUARANTEED_REDEMPTION\";\n    }\n\n    /// @notice Checks whether a particular condition passes the rule for a particular fund\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _adapter The adapter for which to check the rule\n    /// @return isValid_ True if the rule passes\n    function passesRule(address _comptrollerProxy, address _adapter)\n        public\n        view\n        returns (bool isValid_)\n    {\n        if (!adapterCanBlockRedemption(_adapter)) {\n            return true;\n        }\n\n\n            RedemptionWindow memory redemptionWindow\n         = comptrollerProxyToRedemptionWindow[_comptrollerProxy];\n\n        // If no RedemptionWindow is set, the fund can never use redemption-blocking adapters\n        if (redemptionWindow.startTimestamp == 0) {\n            return false;\n        }\n\n        uint256 latestRedemptionWindowStart = calcLatestRedemptionWindowStart(\n            redemptionWindow.startTimestamp\n        );\n\n        // A fund can't trade during its redemption window, nor in the buffer beforehand.\n        // The lower bound is only relevant when the startTimestamp is in the future,\n        // so we check it last.\n        if (\n            block.timestamp >= latestRedemptionWindowStart.add(redemptionWindow.duration) ||\n            block.timestamp <= latestRedemptionWindowStart.sub(redemptionWindowBuffer)\n        ) {\n            return true;\n        }\n\n        return false;\n    }\n\n    /// @notice Sets a new value for the redemptionWindowBuffer variable\n    /// @param _nextRedemptionWindowBuffer The number of seconds for the redemptionWindowBuffer\n    /// @dev The redemptionWindowBuffer is added to the beginning of the redemption window,\n    /// and should always be >= the longest potential block on redemption amongst all adapters.\n    /// (e.g., Synthetix blocks token transfers during a timelock after trading synths)\n    function setRedemptionWindowBuffer(uint256 _nextRedemptionWindowBuffer)\n        external\n        onlyFundDeployerOwner\n    {\n        uint256 prevRedemptionWindowBuffer = redemptionWindowBuffer;\n        require(\n            _nextRedemptionWindowBuffer != prevRedemptionWindowBuffer,\n            \"setRedemptionWindowBuffer: Value already set\"\n        );\n\n        redemptionWindowBuffer = _nextRedemptionWindowBuffer;\n\n        emit RedemptionWindowBufferSet(prevRedemptionWindowBuffer, _nextRedemptionWindowBuffer);\n    }\n\n    /// @notice Apply the rule with the specified parameters of a PolicyHook\n    /// @param _comptrollerProxy The fund's ComptrollerProxy address\n    /// @param _encodedArgs Encoded args with which to validate the rule\n    /// @return isValid_ True if the rule passes\n    function validateRule(\n        address _comptrollerProxy,\n        address,\n        IPolicyManager.PolicyHook,\n        bytes calldata _encodedArgs\n    ) external override returns (bool isValid_) {\n        (address adapter, ) = __decodeRuleArgs(_encodedArgs);\n\n        return passesRule(_comptrollerProxy, adapter);\n    }\n\n    // PUBLIC FUNCTIONS\n\n    /// @notice Calculates the start of the most recent redemption window\n    /// @param _startTimestamp The initial startTimestamp for the redemption window\n    /// @return latestRedemptionWindowStart_ The starting timestamp of the most recent redemption window\n    function calcLatestRedemptionWindowStart(uint256 _startTimestamp)\n        public\n        view\n        returns (uint256 latestRedemptionWindowStart_)\n    {\n        if (block.timestamp <= _startTimestamp) {\n            return _startTimestamp;\n        }\n\n        uint256 timeSinceStartTimestamp = block.timestamp.sub(_startTimestamp);\n        uint256 timeSincePeriodStart = timeSinceStartTimestamp.mod(ONE_DAY);\n\n        return block.timestamp.sub(timeSincePeriodStart);\n    }\n\n    ///////////////////////////////////////////\n    // REDEMPTION-BLOCKING ADAPTERS REGISTRY //\n    ///////////////////////////////////////////\n\n    /// @notice Add adapters which can block shares redemption\n    /// @param _adapters The addresses of adapters to be added\n    function addRedemptionBlockingAdapters(address[] calldata _adapters)\n        external\n        onlyFundDeployerOwner\n    {\n        require(\n            _adapters.length > 0,\n            \"__addRedemptionBlockingAdapters: _adapters cannot be empty\"\n        );\n\n        __addRedemptionBlockingAdapters(_adapters);\n    }\n\n    /// @notice Remove adapters which can block shares redemption\n    /// @param _adapters The addresses of adapters to be removed\n    function removeRedemptionBlockingAdapters(address[] calldata _adapters)\n        external\n        onlyFundDeployerOwner\n    {\n        require(\n            _adapters.length > 0,\n            \"removeRedemptionBlockingAdapters: _adapters cannot be empty\"\n        );\n\n        for (uint256 i; i < _adapters.length; i++) {\n            require(\n                adapterCanBlockRedemption(_adapters[i]),\n                \"removeRedemptionBlockingAdapters: adapter is not added\"\n            );\n\n            adapterToCanBlockRedemption[_adapters[i]] = false;\n\n            emit AdapterRemoved(_adapters[i]);\n        }\n    }\n\n    /// @dev Helper to mark adapters that can block shares redemption\n    function __addRedemptionBlockingAdapters(address[] memory _adapters) private {\n        for (uint256 i; i < _adapters.length; i++) {\n            require(\n                _adapters[i] != address(0),\n                \"__addRedemptionBlockingAdapters: adapter cannot be empty\"\n            );\n            require(\n                !adapterCanBlockRedemption(_adapters[i]),\n                \"__addRedemptionBlockingAdapters: adapter already added\"\n            );\n\n            adapterToCanBlockRedemption[_adapters[i]] = true;\n\n            emit AdapterAdded(_adapters[i]);\n        }\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the `redemptionWindowBuffer` variable\n    /// @return redemptionWindowBuffer_ The `redemptionWindowBuffer` variable value\n    function getRedemptionWindowBuffer() external view returns (uint256 redemptionWindowBuffer_) {\n        return redemptionWindowBuffer;\n    }\n\n    /// @notice Gets the RedemptionWindow settings for a given fund\n    /// @param _comptrollerProxy The ComptrollerProxy of the fund\n    /// @return redemptionWindow_ The RedemptionWindow settings\n    function getRedemptionWindowForFund(address _comptrollerProxy)\n        external\n        view\n        returns (RedemptionWindow memory redemptionWindow_)\n    {\n        return comptrollerProxyToRedemptionWindow[_comptrollerProxy];\n    }\n\n    /// @notice Checks whether an adapter can block shares redemption\n    /// @param _adapter The address of the adapter to check\n    /// @return canBlockRedemption_ True if the adapter can block shares redemption\n    function adapterCanBlockRedemption(address _adapter)\n        public\n        view\n        returns (bool canBlockRedemption_)\n    {\n        return adapterToCanBlockRedemption[_adapter];\n    }\n}\n"
    },
    "contracts/release/extensions/policy-manager/policies/call-on-integration/utils/PreCallOnIntegrationValidatePolicyBase.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../utils/PolicyBase.sol\";\n\n/// @title CallOnIntegrationPreValidatePolicyMixin Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A mixin contract for policies that only implement the PreCallOnIntegration policy hook\nabstract contract PreCallOnIntegrationValidatePolicyBase is PolicyBase {\n    /// @notice Gets the implemented PolicyHooks for a policy\n    /// @return implementedHooks_ The implemented PolicyHooks\n    function implementedHooks()\n        external\n        view\n        override\n        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)\n    {\n        implementedHooks_ = new IPolicyManager.PolicyHook[](1);\n        implementedHooks_[0] = IPolicyManager.PolicyHook.PreCallOnIntegration;\n\n        return implementedHooks_;\n    }\n\n    /// @notice Helper to decode rule arguments\n    function __decodeRuleArgs(bytes memory _encodedRuleArgs)\n        internal\n        pure\n        returns (address adapter_, bytes4 selector_)\n    {\n        return abi.decode(_encodedRuleArgs, (address, bytes4));\n    }\n}\n"
    },
    "contracts/release/extensions/policy-manager/policies/utils/PolicyBase.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../IPolicy.sol\";\n\n/// @title PolicyBase Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice Abstract base contract for all policies\nabstract contract PolicyBase is IPolicy {\n    address internal immutable POLICY_MANAGER;\n\n    modifier onlyPolicyManager {\n        require(msg.sender == POLICY_MANAGER, \"Only the PolicyManager can make this call\");\n        _;\n    }\n\n    constructor(address _policyManager) public {\n        POLICY_MANAGER = _policyManager;\n    }\n\n    /// @notice Validates and initializes a policy as necessary prior to fund activation\n    /// @dev Unimplemented by default, can be overridden by the policy\n    function activateForFund(address, address) external virtual override {\n        return;\n    }\n\n    /// @notice Updates the policy settings for a fund\n    /// @dev Disallowed by default, can be overridden by the policy\n    function updateFundSettings(\n        address,\n        address,\n        bytes calldata\n    ) external virtual override {\n        revert(\"updateFundSettings: Updates not allowed for this policy\");\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the `POLICY_MANAGER` variable value\n    /// @return policyManager_ The `POLICY_MANAGER` variable value\n    function getPolicyManager() external view returns (address policyManager_) {\n        return POLICY_MANAGER;\n    }\n}\n"
    },
    "contracts/release/extensions/utils/FundDeployerOwnerMixin.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n/*\n    This file is part of the Enzyme Protocol.\n\n    (c) Enzyme Council <council@enzyme.finance>\n\n    For the full license information, please view the LICENSE\n    file that was distributed with this source code.\n*/\n\npragma solidity 0.6.12;\n\nimport \"../../core/fund-deployer/IFundDeployer.sol\";\n\n/// @title FundDeployerOwnerMixin Contract\n/// @author Enzyme Council <security@enzyme.finance>\n/// @notice A mixin contract that defers ownership to the owner of FundDeployer\nabstract contract FundDeployerOwnerMixin {\n    address internal immutable FUND_DEPLOYER;\n\n    modifier onlyFundDeployerOwner() {\n        require(\n            msg.sender == getOwner(),\n            \"onlyFundDeployerOwner: Only the FundDeployer owner can call this function\"\n        );\n        _;\n    }\n\n    constructor(address _fundDeployer) public {\n        FUND_DEPLOYER = _fundDeployer;\n    }\n\n    /// @notice Gets the owner of this contract\n    /// @return owner_ The owner\n    /// @dev Ownership is deferred to the owner of the FundDeployer contract\n    function getOwner() public view returns (address owner_) {\n        return IFundDeployer(FUND_DEPLOYER).getOwner();\n    }\n\n    ///////////////////\n    // STATE GETTERS //\n    ///////////////////\n\n    /// @notice Gets the `FUND_DEPLOYER` variable\n    /// @return fundDeployer_ The `FUND_DEPLOYER` variable value\n    function getFundDeployer() external view returns (address fundDeployer_) {\n        return FUND_DEPLOYER;\n    }\n}\n"
    }
  }
}}