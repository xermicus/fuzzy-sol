{{
  "language": "Solidity",
  "sources": {
    "@openzeppelin/contracts/math/SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Wrappers over Solidity's arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it's recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        uint256 c = a + b;\n        if (c < a) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b > a) return (false, 0);\n        return (true, a - b);\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) return (true, 0);\n        uint256 c = a * b;\n        if (c / a != b) return (false, 0);\n        return (true, c);\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a / b);\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        if (b == 0) return (false, 0);\n        return (true, a % b);\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b <= a, \"SafeMath: subtraction overflow\");\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity's `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) return 0;\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b > 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity's `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryDiv}.\n     *\n     * Counterpart to Solidity's `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity's `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b > 0, errorMessage);\n        return a % b;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "/contracts/contract/RocketBase.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\nimport \"../interface/RocketStorageInterface.sol\";\n\n/// @title Base settings / modifiers for each contract in Rocket Pool\n/// @author David Rugendyke\n\nabstract contract RocketBase {\n\n    // Calculate using this as the base\n    uint256 constant calcBase = 1 ether;\n\n    // Version of the contract\n    uint8 public version;\n\n    // The main storage contract where primary persistant storage is maintained\n    RocketStorageInterface rocketStorage = RocketStorageInterface(0);\n\n\n    /*** Modifiers **********************************************************/\n\n    /**\n    * @dev Throws if called by any sender that doesn't match a Rocket Pool network contract\n    */\n    modifier onlyLatestNetworkContract() {\n        require(getBool(keccak256(abi.encodePacked(\"contract.exists\", msg.sender))), \"Invalid or outdated network contract\");\n        _;\n    }\n\n    /**\n    * @dev Throws if called by any sender that doesn't match one of the supplied contract or is the latest version of that contract\n    */\n    modifier onlyLatestContract(string memory _contractName, address _contractAddress) {\n        require(_contractAddress == getAddress(keccak256(abi.encodePacked(\"contract.address\", _contractName))), \"Invalid or outdated contract\");\n        _;\n    }\n\n    /**\n    * @dev Throws if called by any sender that isn't a registered node\n    */\n    modifier onlyRegisteredNode(address _nodeAddress) {\n        require(getBool(keccak256(abi.encodePacked(\"node.exists\", _nodeAddress))), \"Invalid node\");\n        _;\n    }\n\n    /**\n    * @dev Throws if called by any sender that isn't a trusted node DAO member\n    */\n    modifier onlyTrustedNode(address _nodeAddress) {\n        require(getBool(keccak256(abi.encodePacked(\"dao.trustednodes.\", \"member\", _nodeAddress))), \"Invalid trusted node\");\n        _;\n    }\n\n    /**\n    * @dev Throws if called by any sender that isn't a registered minipool\n    */\n    modifier onlyRegisteredMinipool(address _minipoolAddress) {\n        require(getBool(keccak256(abi.encodePacked(\"minipool.exists\", _minipoolAddress))), \"Invalid minipool\");\n        _;\n    }\n    \n\n    /**\n    * @dev Throws if called by any account other than a guardian account (temporary account allowed access to settings before DAO is fully enabled)\n    */\n    modifier onlyGuardian() {\n        require(msg.sender == rocketStorage.getGuardian(), \"Account is not a temporary guardian\");\n        _;\n    }\n\n\n\n\n    /*** Methods **********************************************************/\n\n    /// @dev Set the main Rocket Storage address\n    constructor(RocketStorageInterface _rocketStorageAddress) {\n        // Update the contract address\n        rocketStorage = RocketStorageInterface(_rocketStorageAddress);\n    }\n\n\n    /// @dev Get the address of a network contract by name\n    function getContractAddress(string memory _contractName) internal view returns (address) {\n        // Get the current contract address\n        address contractAddress = getAddress(keccak256(abi.encodePacked(\"contract.address\", _contractName)));\n        // Check it\n        require(contractAddress != address(0x0), \"Contract not found\");\n        // Return\n        return contractAddress;\n    }\n\n\n    /// @dev Get the address of a network contract by name (returns address(0x0) instead of reverting if contract does not exist)\n    function getContractAddressUnsafe(string memory _contractName) internal view returns (address) {\n        // Get the current contract address\n        address contractAddress = getAddress(keccak256(abi.encodePacked(\"contract.address\", _contractName)));\n        // Return\n        return contractAddress;\n    }\n\n\n    /// @dev Get the name of a network contract by address\n    function getContractName(address _contractAddress) internal view returns (string memory) {\n        // Get the contract name\n        string memory contractName = getString(keccak256(abi.encodePacked(\"contract.name\", _contractAddress)));\n        // Check it\n        require(bytes(contractName).length > 0, \"Contract not found\");\n        // Return\n        return contractName;\n    }\n\n    /// @dev Get revert error message from a .call method\n    function getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {\n        // If the _res length is less than 68, then the transaction failed silently (without a revert message)\n        if (_returnData.length < 68) return \"Transaction reverted silently\";\n        assembly {\n            // Slice the sighash.\n            _returnData := add(_returnData, 0x04)\n        }\n        return abi.decode(_returnData, (string)); // All that remains is the revert string\n    }\n\n\n\n    /*** Rocket Storage Methods ****************************************/\n\n    // Note: Unused helpers have been removed to keep contract sizes down\n\n    /// @dev Storage get methods\n    function getAddress(bytes32 _key) internal view returns (address) { return rocketStorage.getAddress(_key); }\n    function getUint(bytes32 _key) internal view returns (uint) { return rocketStorage.getUint(_key); }\n    function getString(bytes32 _key) internal view returns (string memory) { return rocketStorage.getString(_key); }\n    function getBytes(bytes32 _key) internal view returns (bytes memory) { return rocketStorage.getBytes(_key); }\n    function getBool(bytes32 _key) internal view returns (bool) { return rocketStorage.getBool(_key); }\n    function getInt(bytes32 _key) internal view returns (int) { return rocketStorage.getInt(_key); }\n    function getBytes32(bytes32 _key) internal view returns (bytes32) { return rocketStorage.getBytes32(_key); }\n\n    /// @dev Storage set methods\n    function setAddress(bytes32 _key, address _value) internal { rocketStorage.setAddress(_key, _value); }\n    function setUint(bytes32 _key, uint _value) internal { rocketStorage.setUint(_key, _value); }\n    function setString(bytes32 _key, string memory _value) internal { rocketStorage.setString(_key, _value); }\n    function setBytes(bytes32 _key, bytes memory _value) internal { rocketStorage.setBytes(_key, _value); }\n    function setBool(bytes32 _key, bool _value) internal { rocketStorage.setBool(_key, _value); }\n    function setInt(bytes32 _key, int _value) internal { rocketStorage.setInt(_key, _value); }\n    function setBytes32(bytes32 _key, bytes32 _value) internal { rocketStorage.setBytes32(_key, _value); }\n\n    /// @dev Storage delete methods\n    function deleteAddress(bytes32 _key) internal { rocketStorage.deleteAddress(_key); }\n    function deleteUint(bytes32 _key) internal { rocketStorage.deleteUint(_key); }\n    function deleteString(bytes32 _key) internal { rocketStorage.deleteString(_key); }\n    function deleteBytes(bytes32 _key) internal { rocketStorage.deleteBytes(_key); }\n    function deleteBool(bytes32 _key) internal { rocketStorage.deleteBool(_key); }\n    function deleteInt(bytes32 _key) internal { rocketStorage.deleteInt(_key); }\n    function deleteBytes32(bytes32 _key) internal { rocketStorage.deleteBytes32(_key); }\n\n    /// @dev Storage arithmetic methods\n    function addUint(bytes32 _key, uint256 _amount) internal { rocketStorage.addUint(_key, _amount); }\n    function subUint(bytes32 _key, uint256 _amount) internal { rocketStorage.subUint(_key, _amount); }\n}\n"
    },
    "/contracts/contract/dao/protocol/settings/RocketDAOProtocolSettings.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\nimport \"../../../RocketBase.sol\";\nimport \"../../../../interface/dao/protocol/settings/RocketDAOProtocolSettingsInterface.sol\";\n\n// Settings in RP which the DAO will have full control over\n// This settings contract enables storage using setting paths with namespaces, rather than explicit set methods\nabstract contract RocketDAOProtocolSettings is RocketBase, RocketDAOProtocolSettingsInterface {\n\n\n    // The namespace for a particular group of settings\n    bytes32 settingNameSpace;\n\n\n    // Only allow updating from the DAO proposals contract\n    modifier onlyDAOProtocolProposal() {\n        // If this contract has been initialised, only allow access from the proposals contract\n        if(getBool(keccak256(abi.encodePacked(settingNameSpace, \"deployed\")))) require(getContractAddress(\"rocketDAOProtocolProposals\") == msg.sender, \"Only DAO Protocol Proposals contract can update a setting\");\n        _;\n    }\n\n\n    // Construct\n    constructor(RocketStorageInterface _rocketStorageAddress, string memory _settingNameSpace) RocketBase(_rocketStorageAddress) {\n        // Apply the setting namespace\n        settingNameSpace = keccak256(abi.encodePacked(\"dao.protocol.setting.\", _settingNameSpace));\n    }\n\n\n    /*** Uints  ****************/\n\n    // A general method to return any setting given the setting path is correct, only accepts uints\n    function getSettingUint(string memory _settingPath) public view override returns (uint256) {\n        return getUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));\n    } \n\n    // Update a Uint setting, can only be executed by the DAO contract when a majority on a setting proposal has passed and been executed\n    function setSettingUint(string memory _settingPath, uint256 _value) virtual public override onlyDAOProtocolProposal {\n        // Update setting now\n        setUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);\n    } \n   \n\n    /*** Bools  ****************/\n\n    // A general method to return any setting given the setting path is correct, only accepts bools\n    function getSettingBool(string memory _settingPath) public view override returns (bool) {\n        return getBool(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));\n    } \n\n    // Update a setting, can only be executed by the DAO contract when a majority on a setting proposal has passed and been executed\n    function setSettingBool(string memory _settingPath, bool _value) virtual public override onlyDAOProtocolProposal {\n        // Update setting now\n        setBool(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);\n    }\n\n    \n    /*** Addresses  ****************/\n\n    // A general method to return any setting given the setting path is correct, only accepts addresses\n    function getSettingAddress(string memory _settingPath) external view override returns (address) {\n        return getAddress(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));\n    } \n\n    // Update a setting, can only be executed by the DAO contract when a majority on a setting proposal has passed and been executed\n    function setSettingAddress(string memory _settingPath, address _value) virtual external override onlyDAOProtocolProposal {\n        // Update setting now\n        setAddress(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);\n    }\n\n}\n"
    },
    "/contracts/contract/dao/protocol/settings/RocketDAOProtocolSettingsInflation.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\nimport \"./RocketDAOProtocolSettings.sol\";\nimport \"../../../../interface/dao/protocol/settings/RocketDAOProtocolSettingsInflationInterface.sol\";\nimport \"../../../../interface/token/RocketTokenRPLInterface.sol\";\n\nimport \"@openzeppelin/contracts/math/SafeMath.sol\";\n\n// RPL Inflation settings in RP which the DAO will have full control over\ncontract RocketDAOProtocolSettingsInflation is RocketDAOProtocolSettings, RocketDAOProtocolSettingsInflationInterface {\n\n    // Construct\n    constructor(RocketStorageInterface _rocketStorageAddress) RocketDAOProtocolSettings(_rocketStorageAddress, \"inflation\") {\n        // Set version \n        version = 1;\n         // Set some initial settings on first deployment\n        if(!getBool(keccak256(abi.encodePacked(settingNameSpace, \"deployed\")))) {\n            // RPL Inflation settings\n            setSettingUint(\"rpl.inflation.interval.rate\", 1000133680617113500);                                 // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);\n            setSettingUint(\"rpl.inflation.interval.start\", block.timestamp + 1 days);                           // Set the default start date for inflation to begin as 1 day after deployment\n            // Deployment check\n            setBool(keccak256(abi.encodePacked(settingNameSpace, \"deployed\")), true);                           // Flag that this contract has been deployed, so default settings don't get reapplied on a contract upgrade\n        }\n    }\n    \n    \n\n    /*** Set Uint *****************************************/\n\n    // Update a setting, overrides inherited setting method with extra checks for this contract\n    function setSettingUint(string memory _settingPath, uint256 _value) override public onlyDAOProtocolProposal {\n        // Some safety guards for certain settings\n        // The start time for inflation must be in the future and cannot be set again once started\n        bytes32 settingKey = keccak256(bytes(_settingPath));\n        if(settingKey == keccak256(bytes(\"rpl.inflation.interval.start\"))) {\n            // Must be a future timestamp\n            require(_value > block.timestamp, \"Inflation interval start time must be in the future\");\n            // If it's already set and started, a new start block cannot be set\n            if(getInflationIntervalStartTime() > 0) {\n                require(getInflationIntervalStartTime() > block.timestamp, \"Inflation has already started\");\n            }\n        } else if(settingKey == keccak256(bytes(\"rpl.inflation.interval.rate\"))) {\n            // RPL contract address\n            address rplContractAddress = getContractAddressUnsafe(\"rocketTokenRPL\");\n            if(rplContractAddress != address(0x0)) {\n                // Force inflation at old rate before updating inflation rate\n                RocketTokenRPLInterface rplContract = RocketTokenRPLInterface(rplContractAddress);\n                // Mint any new tokens from the RPL inflation\n                rplContract.inflationMintTokens();\n            }\n        }\n        // Update setting now\n        setUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);\n    }\n\n    /*** RPL Contract Settings *****************************************/\n\n    // RPL yearly inflation rate per interval (daily by default)\n    function getInflationIntervalRate() override external view returns (uint256) {\n        return getSettingUint(\"rpl.inflation.interval.rate\");\n    }\n    \n    // The block to start inflation at\n    function getInflationIntervalStartTime() override public view returns (uint256) {\n        return getSettingUint(\"rpl.inflation.interval.start\"); \n    }\n\n}\n"
    },
    "/contracts/interface/RocketStorageInterface.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\ninterface RocketStorageInterface {\n\n    // Deploy status\n    function getDeployedStatus() external view returns (bool);\n\n    // Guardian\n    function getGuardian() external view returns(address);\n    function setGuardian(address _newAddress) external;\n    function confirmGuardian() external;\n\n    // Getters\n    function getAddress(bytes32 _key) external view returns (address);\n    function getUint(bytes32 _key) external view returns (uint);\n    function getString(bytes32 _key) external view returns (string memory);\n    function getBytes(bytes32 _key) external view returns (bytes memory);\n    function getBool(bytes32 _key) external view returns (bool);\n    function getInt(bytes32 _key) external view returns (int);\n    function getBytes32(bytes32 _key) external view returns (bytes32);\n\n    // Setters\n    function setAddress(bytes32 _key, address _value) external;\n    function setUint(bytes32 _key, uint _value) external;\n    function setString(bytes32 _key, string calldata _value) external;\n    function setBytes(bytes32 _key, bytes calldata _value) external;\n    function setBool(bytes32 _key, bool _value) external;\n    function setInt(bytes32 _key, int _value) external;\n    function setBytes32(bytes32 _key, bytes32 _value) external;\n\n    // Deleters\n    function deleteAddress(bytes32 _key) external;\n    function deleteUint(bytes32 _key) external;\n    function deleteString(bytes32 _key) external;\n    function deleteBytes(bytes32 _key) external;\n    function deleteBool(bytes32 _key) external;\n    function deleteInt(bytes32 _key) external;\n    function deleteBytes32(bytes32 _key) external;\n\n    // Arithmetic\n    function addUint(bytes32 _key, uint256 _amount) external;\n    function subUint(bytes32 _key, uint256 _amount) external;\n\n    // Protected storage\n    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);\n    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);\n    function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external;\n    function confirmWithdrawalAddress(address _nodeAddress) external;\n}\n"
    },
    "/contracts/interface/dao/protocol/settings/RocketDAOProtocolSettingsInflationInterface.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\ninterface RocketDAOProtocolSettingsInflationInterface {\n    function getInflationIntervalRate() external view returns (uint256);\n    function getInflationIntervalStartTime() external view returns (uint256);\n}\n"
    },
    "/contracts/interface/dao/protocol/settings/RocketDAOProtocolSettingsInterface.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\ninterface RocketDAOProtocolSettingsInterface {\n    function getSettingUint(string memory _settingPath) external view returns (uint256);\n    function setSettingUint(string memory _settingPath, uint256 _value) external;\n    function getSettingBool(string memory _settingPath) external view returns (bool);\n    function setSettingBool(string memory _settingPath, bool _value) external;\n    function getSettingAddress(string memory _settingPath) external view returns (address);\n    function setSettingAddress(string memory _settingPath, address _value) external;\n}\n"
    },
    "/contracts/interface/token/RocketTokenRPLInterface.sol": {
      "content": "/**\n  *       .\n  *      / \\\n  *     |.'.|\n  *     |'.'|\n  *   ,'|   |`.\n  *  |,-'-|-'-.|\n  *   __|_| |         _        _      _____           _\n  *  | ___ \\|        | |      | |    | ___ \\         | |\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\n  * +---------------------------------------------------+\n  * |    DECENTRALISED STAKING PROTOCOL FOR ETHEREUM    |\n  * +---------------------------------------------------+\n  *\n  *  Rocket Pool is a first-of-its-kind Ethereum staking pool protocol, designed to\n  *  be community-owned, decentralised, and trustless.\n  *\n  *  For more information about Rocket Pool, visit https://rocketpool.net\n  *\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\n  *\n  */\n\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ninterface RocketTokenRPLInterface is IERC20 {\n    function getInflationCalcTime() external view returns(uint256);\n    function getInflationIntervalTime() external view returns(uint256);\n    function getInflationIntervalRate() external view returns(uint256);\n    function getInflationIntervalsPassed() external view returns(uint256);\n    function getInflationIntervalStartTime() external view returns(uint256);\n    function getInflationRewardsContractAddress() external view returns(address);\n    function inflationCalculate() external view returns (uint256);\n    function inflationMintTokens() external returns (uint256);\n    function swapTokens(uint256 _amount) external;\n}\n"
    }
  },
  "settings": {
    "remappings": [],
    "optimizer": {
      "enabled": true,
      "runs": 15000
    },
    "evmVersion": "istanbul",
    "libraries": {},
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
  }
}}