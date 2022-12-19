{{
  "language": "Solidity",
  "sources": {
    "/contracts/contract/minipool/RocketMinipool.sol": {
      "content": "/**\r\n  *       .\r\n  *      / \\\r\n  *     |.'.|\r\n  *     |'.'|\r\n  *   ,'|   |`.\r\n  *  |,-'-|-'-.|\r\n  *   __|_| |         _        _      _____           _\r\n  *  | ___ \\|        | |      | |    | ___ \\         | |\r\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\r\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\r\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\r\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\r\n  * +---------------------------------------------------+\r\n  * |  DECENTRALISED STAKING PROTOCOL FOR ETHEREUM 2.0  |\r\n  * +---------------------------------------------------+\r\n  *\r\n  *  Rocket Pool is a first-of-its-kind ETH2 Proof of Stake protocol, designed to be community owned,\r\n  *  decentralised, trustless and compatible with staking in Ethereum 2.0.\r\n  *\r\n  *  For more information about Rocket Pool, visit https://rocketpool.net\r\n  *\r\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\r\n  *\r\n  */\r\n\r\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\nimport \"./RocketMinipoolStorageLayout.sol\";\nimport \"../../interface/RocketStorageInterface.sol\";\nimport \"../../types/MinipoolDeposit.sol\";\nimport \"../../types/MinipoolStatus.sol\";\n\n// An individual minipool in the Rocket Pool network\n\ncontract RocketMinipool is RocketMinipoolStorageLayout {\n\n    // Events\n    event EtherReceived(address indexed from, uint256 amount, uint256 time);\n    event DelegateUpgraded(address oldDelegate, address newDelegate, uint256 time);\n    event DelegateRolledBack(address oldDelegate, address newDelegate, uint256 time);\n\n    // Modifiers\n\n    // Only allow access from the owning node address\n    modifier onlyMinipoolOwner() {\n        // Only the node operator can upgrade\n        address withdrawalAddress = rocketStorage.getNodeWithdrawalAddress(nodeAddress);\n        require(msg.sender == nodeAddress || msg.sender == withdrawalAddress, \"Only the node operator can access this method\");\n        _;\n    }\n\n    // Construct\n    constructor(RocketStorageInterface _rocketStorageAddress, address _nodeAddress, MinipoolDeposit _depositType) {\n        // Initialise RocketStorage\n        require(address(_rocketStorageAddress) != address(0x0), \"Invalid storage address\");\n        rocketStorage = RocketStorageInterface(_rocketStorageAddress);\n        // Set storage state to uninitialised\n        storageState = StorageState.Uninitialised;\n        // Set the current delegate\n        address delegateAddress = getContractAddress(\"rocketMinipoolDelegate\");\n        rocketMinipoolDelegate = delegateAddress;\n        // Check for contract existence\n        require(contractExists(delegateAddress), \"Delegate contract does not exist\");\n        // Call initialise on delegate\n        (bool success, bytes memory data) = delegateAddress.delegatecall(abi.encodeWithSignature('initialise(address,uint8)', _nodeAddress, uint8(_depositType)));\n        if (!success) { revert(getRevertMessage(data)); }\n    }\n\n    // Receive an ETH deposit\n    receive() external payable {\n        // Emit ether received event\n        emit EtherReceived(msg.sender, msg.value, block.timestamp);\n    }\n\n    // Upgrade this minipool to the latest network delegate contract\n    function delegateUpgrade() external onlyMinipoolOwner {\n        // Set previous address\n        rocketMinipoolDelegatePrev = rocketMinipoolDelegate;\n        // Set new delegate\n        rocketMinipoolDelegate = getContractAddress(\"rocketMinipoolDelegate\");\n        // Verify\n        require(rocketMinipoolDelegate != rocketMinipoolDelegatePrev, \"New delegate is the same as the existing one\");\n        // Log event\n        emit DelegateUpgraded(rocketMinipoolDelegatePrev, rocketMinipoolDelegate, block.timestamp);\n    }\n\n    // Rollback to previous delegate contract\n    function delegateRollback() external onlyMinipoolOwner {\n        // Make sure they have upgraded before\n        require(rocketMinipoolDelegatePrev != address(0x0), \"Previous delegate contract is not set\");\n        // Store original\n        address originalDelegate = rocketMinipoolDelegate;\n        // Update delegate to previous and zero out previous\n        rocketMinipoolDelegate = rocketMinipoolDelegatePrev;\n        rocketMinipoolDelegatePrev = address(0x0);\n        // Log event\n        emit DelegateRolledBack(originalDelegate, rocketMinipoolDelegate, block.timestamp);\n    }\n\n    // If set to true, will automatically use the latest delegate contract\n    function setUseLatestDelegate(bool _setting) external onlyMinipoolOwner {\n        useLatestDelegate = _setting;\n    }\n\n    // Getter for useLatestDelegate setting\n    function getUseLatestDelegate() external view returns (bool) {\n        return useLatestDelegate;\n    }\n\n    // Returns the address of the minipool's stored delegate\n    function getDelegate() external view returns (address) {\n        return rocketMinipoolDelegate;\n    }\n\n    // Returns the address of the minipool's previous delegate (or address(0) if not set)\n    function getPreviousDelegate() external view returns (address) {\n        return rocketMinipoolDelegatePrev;\n    }\n\n    // Returns the delegate which will be used when calling this minipool taking into account useLatestDelegate setting\n    function getEffectiveDelegate() external view returns (address) {\n        return useLatestDelegate ? getContractAddress(\"rocketMinipoolDelegate\") : rocketMinipoolDelegate;\n    }\n\n    // Delegate all other calls to minipool delegate contract\n    fallback(bytes calldata _input) external payable returns (bytes memory) {\n        // If useLatestDelegate is set, use the latest delegate contract\n        address delegateContract = useLatestDelegate ? getContractAddress(\"rocketMinipoolDelegate\") : rocketMinipoolDelegate;\n        // Check for contract existence\n        require(contractExists(delegateContract), \"Delegate contract does not exist\");\n        // Execute delegatecall\n        (bool success, bytes memory data) = delegateContract.delegatecall(_input);\n        if (!success) { revert(getRevertMessage(data)); }\n        return data;\n    }\n\n    // Get the address of a Rocket Pool network contract\n    function getContractAddress(string memory _contractName) private view returns (address) {\n        address contractAddress = rocketStorage.getAddress(keccak256(abi.encodePacked(\"contract.address\", _contractName)));\n        require(contractAddress != address(0x0), \"Contract not found\");\n        return contractAddress;\n    }\n\n    // Get a revert message from delegatecall return data\n    function getRevertMessage(bytes memory _returnData) private pure returns (string memory) {\n        if (_returnData.length < 68) { return \"Transaction reverted silently\"; }\n        assembly {\n            _returnData := add(_returnData, 0x04)\n        }\n        return abi.decode(_returnData, (string));\n    }\n\n    // Returns true if contract exists at _contractAddress (if called during that contract's construction it will return a false negative)\n    function contractExists(address _contractAddress) private returns (bool) {\n        uint32 codeSize;\n        assembly {\n            codeSize := extcodesize(_contractAddress)\n        }\n        return codeSize > 0;\n    }\n}\n"
    },
    "/contracts/contract/minipool/RocketMinipoolStorageLayout.sol": {
      "content": "/**\r\n  *       .\r\n  *      / \\\r\n  *     |.'.|\r\n  *     |'.'|\r\n  *   ,'|   |`.\r\n  *  |,-'-|-'-.|\r\n  *   __|_| |         _        _      _____           _\r\n  *  | ___ \\|        | |      | |    | ___ \\         | |\r\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\r\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\r\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\r\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\r\n  * +---------------------------------------------------+\r\n  * |  DECENTRALISED STAKING PROTOCOL FOR ETHEREUM 2.0  |\r\n  * +---------------------------------------------------+\r\n  *\r\n  *  Rocket Pool is a first-of-its-kind ETH2 Proof of Stake protocol, designed to be community owned,\r\n  *  decentralised, trustless and compatible with staking in Ethereum 2.0.\r\n  *\r\n  *  For more information about Rocket Pool, visit https://rocketpool.net\r\n  *\r\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\r\n  *\r\n  */\r\n\r\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\nimport \"../../interface/RocketStorageInterface.sol\";\nimport \"../../types/MinipoolDeposit.sol\";\nimport \"../../types/MinipoolStatus.sol\";\n\n// The RocketMinipool contract storage layout, shared by RocketMinipoolDelegate\n\n// ******************************************************\n// Note: This contract MUST NOT BE UPDATED after launch.\n// All deployed minipool contracts must maintain a\n// Consistent storage layout with RocketMinipoolDelegate.\n// ******************************************************\n\nabstract contract RocketMinipoolStorageLayout {\n    // Storage state enum\n    enum StorageState {\n        Undefined,\n        Uninitialised,\n        Initialised\n    }\n\n\t// Main Rocket Pool storage contract\n    RocketStorageInterface internal rocketStorage = RocketStorageInterface(0);\n\n    // Status\n    MinipoolStatus internal status;\n    uint256 internal statusBlock;\n    uint256 internal statusTime;\n    uint256 internal withdrawalBlock;\n\n    // Deposit type\n    MinipoolDeposit internal depositType;\n\n    // Node details\n    address internal nodeAddress;\n    uint256 internal nodeFee;\n    uint256 internal nodeDepositBalance;\n    bool internal nodeDepositAssigned;\n    uint256 internal nodeRefundBalance;\n    uint256 internal nodeSlashBalance;\n\n    // User deposit details\n    uint256 internal userDepositBalance;\n    uint256 internal userDepositAssignedTime;\n\n    // Upgrade options\n    bool internal useLatestDelegate = false;\n    address internal rocketMinipoolDelegate;\n    address internal rocketMinipoolDelegatePrev;\n\n    // Local copy of RETH address\n    address internal rocketTokenRETH;\n\n    // Local copy of penalty contract\n    address internal rocketMinipoolPenalty;\n\n    // Used to prevent direct access to delegate and prevent calling initialise more than once\n    StorageState storageState = StorageState.Undefined;\n\n    // Whether node operator has finalised the pool\n    bool internal finalised;\n\n    // Trusted member scrub votes\n    mapping(address => bool) memberScrubVotes;\n    uint256 totalScrubVotes;\n}\n"
    },
    "/contracts/interface/RocketStorageInterface.sol": {
      "content": "/**\r\n  *       .\r\n  *      / \\\r\n  *     |.'.|\r\n  *     |'.'|\r\n  *   ,'|   |`.\r\n  *  |,-'-|-'-.|\r\n  *   __|_| |         _        _      _____           _\r\n  *  | ___ \\|        | |      | |    | ___ \\         | |\r\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\r\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\r\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\r\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\r\n  * +---------------------------------------------------+\r\n  * |  DECENTRALISED STAKING PROTOCOL FOR ETHEREUM 2.0  |\r\n  * +---------------------------------------------------+\r\n  *\r\n  *  Rocket Pool is a first-of-its-kind ETH2 Proof of Stake protocol, designed to be community owned,\r\n  *  decentralised, trustless and compatible with staking in Ethereum 2.0.\r\n  *\r\n  *  For more information about Rocket Pool, visit https://rocketpool.net\r\n  *\r\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\r\n  *\r\n  */\r\n\r\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\ninterface RocketStorageInterface {\n\n    // Deploy status\n    function getDeployedStatus() external view returns (bool);\n\n    // Guardian\n    function getGuardian() external view returns(address);\n    function setGuardian(address _newAddress) external;\n    function confirmGuardian() external;\n\n    // Getters\n    function getAddress(bytes32 _key) external view returns (address);\n    function getUint(bytes32 _key) external view returns (uint);\n    function getString(bytes32 _key) external view returns (string memory);\n    function getBytes(bytes32 _key) external view returns (bytes memory);\n    function getBool(bytes32 _key) external view returns (bool);\n    function getInt(bytes32 _key) external view returns (int);\n    function getBytes32(bytes32 _key) external view returns (bytes32);\n\n    // Setters\n    function setAddress(bytes32 _key, address _value) external;\n    function setUint(bytes32 _key, uint _value) external;\n    function setString(bytes32 _key, string calldata _value) external;\n    function setBytes(bytes32 _key, bytes calldata _value) external;\n    function setBool(bytes32 _key, bool _value) external;\n    function setInt(bytes32 _key, int _value) external;\n    function setBytes32(bytes32 _key, bytes32 _value) external;\n\n    // Deleters\n    function deleteAddress(bytes32 _key) external;\n    function deleteUint(bytes32 _key) external;\n    function deleteString(bytes32 _key) external;\n    function deleteBytes(bytes32 _key) external;\n    function deleteBool(bytes32 _key) external;\n    function deleteInt(bytes32 _key) external;\n    function deleteBytes32(bytes32 _key) external;\n\n    // Arithmetic\n    function addUint(bytes32 _key, uint256 _amount) external;\n    function subUint(bytes32 _key, uint256 _amount) external;\n\n    // Protected storage\n    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);\n    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);\n    function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external;\n    function confirmWithdrawalAddress(address _nodeAddress) external;\n}\n"
    },
    "/contracts/types/MinipoolDeposit.sol": {
      "content": "/**\r\n  *       .\r\n  *      / \\\r\n  *     |.'.|\r\n  *     |'.'|\r\n  *   ,'|   |`.\r\n  *  |,-'-|-'-.|\r\n  *   __|_| |         _        _      _____           _\r\n  *  | ___ \\|        | |      | |    | ___ \\         | |\r\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\r\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\r\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\r\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\r\n  * +---------------------------------------------------+\r\n  * |  DECENTRALISED STAKING PROTOCOL FOR ETHEREUM 2.0  |\r\n  * +---------------------------------------------------+\r\n  *\r\n  *  Rocket Pool is a first-of-its-kind ETH2 Proof of Stake protocol, designed to be community owned,\r\n  *  decentralised, trustless and compatible with staking in Ethereum 2.0.\r\n  *\r\n  *  For more information about Rocket Pool, visit https://rocketpool.net\r\n  *\r\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\r\n  *\r\n  */\r\n\r\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\n// Represents the type of deposits required by a minipool\n\nenum MinipoolDeposit {\n    None,    // Marks an invalid deposit type\n    Full,    // The minipool requires 32 ETH from the node operator, 16 ETH of which will be refinanced from user deposits\n    Half,    // The minipool required 16 ETH from the node operator to be matched with 16 ETH from user deposits\n    Empty    // The minipool requires 0 ETH from the node operator to be matched with 32 ETH from user deposits (trusted nodes only)\n}\n"
    },
    "/contracts/types/MinipoolStatus.sol": {
      "content": "/**\r\n  *       .\r\n  *      / \\\r\n  *     |.'.|\r\n  *     |'.'|\r\n  *   ,'|   |`.\r\n  *  |,-'-|-'-.|\r\n  *   __|_| |         _        _      _____           _\r\n  *  | ___ \\|        | |      | |    | ___ \\         | |\r\n  *  | |_/ /|__   ___| | _____| |_   | |_/ /__   ___ | |\r\n  *  |    // _ \\ / __| |/ / _ \\ __|  |  __/ _ \\ / _ \\| |\r\n  *  | |\\ \\ (_) | (__|   <  __/ |_   | | | (_) | (_) | |\r\n  *  \\_| \\_\\___/ \\___|_|\\_\\___|\\__|  \\_|  \\___/ \\___/|_|\r\n  * +---------------------------------------------------+\r\n  * |  DECENTRALISED STAKING PROTOCOL FOR ETHEREUM 2.0  |\r\n  * +---------------------------------------------------+\r\n  *\r\n  *  Rocket Pool is a first-of-its-kind ETH2 Proof of Stake protocol, designed to be community owned,\r\n  *  decentralised, trustless and compatible with staking in Ethereum 2.0.\r\n  *\r\n  *  For more information about Rocket Pool, visit https://rocketpool.net\r\n  *\r\n  *  Authors: David Rugendyke, Jake Pospischil, Kane Wallmann, Darren Langley, Joe Clapis, Nick Doherty\r\n  *\r\n  */\r\n\r\npragma solidity 0.7.6;\n\n// SPDX-License-Identifier: GPL-3.0-only\n\n// Represents a minipool's status within the network\n\nenum MinipoolStatus {\n    Initialised,    // The minipool has been initialised and is awaiting a deposit of user ETH\n    Prelaunch,      // The minipool has enough ETH to begin staking and is awaiting launch by the node operator\n    Staking,        // The minipool is currently staking\n    Withdrawable,   // The minipool has become withdrawable on the beacon chain and can be withdrawn from by the node operator\n    Dissolved       // The minipool has been dissolved and its user deposited ETH has been returned to the deposit pool\n}\n"
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
          "abi"
        ]
      }
    }
  }
}}