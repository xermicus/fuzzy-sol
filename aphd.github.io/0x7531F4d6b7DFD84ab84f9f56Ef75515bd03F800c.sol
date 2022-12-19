{"BaseFeature.sol":{"content":"// Copyright (C) 2018  Argent Labs Ltd. \u003chttps://argent.xyz\u003e\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.s\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.6.12;\n\nimport \"./SafeMath.sol\";\nimport \"./IWallet.sol\";\nimport \"./IModuleRegistry.sol\";\nimport \"./ILockStorage.sol\";\nimport \"./IFeature.sol\";\nimport \"./ERC20.sol\";\nimport \"./IVersionManager.sol\";\n\n/**\n * @title BaseFeature\n * @notice Base Feature contract that contains methods common to all Feature contracts.\n * @author Julien Niset - \u003cjulien@argent.xyz\u003e, Olivier VDB - \u003colivier@argent.xyz\u003e\n */\ncontract BaseFeature is IFeature {\n\n    // Empty calldata\n    bytes constant internal EMPTY_BYTES = \"\";\n    // Mock token address for ETH\n    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n    // The address of the Lock storage\n    ILockStorage internal lockStorage;\n    // The address of the Version Manager\n    IVersionManager internal versionManager;\n\n    event FeatureCreated(bytes32 name);\n\n    /**\n     * @notice Throws if the wallet is locked.\n     */\n    modifier onlyWhenUnlocked(address _wallet) {\n        require(!lockStorage.isLocked(_wallet), \"BF: wallet locked\");\n        _;\n    }\n\n    /**\n     * @notice Throws if the sender is not the VersionManager.\n     */\n    modifier onlyVersionManager() {\n        require(msg.sender == address(versionManager), \"BF: caller must be VersionManager\");\n        _;\n    }\n\n    /**\n     * @notice Throws if the sender is not the owner of the target wallet.\n     */\n    modifier onlyWalletOwner(address _wallet) {\n        require(isOwner(_wallet, msg.sender), \"BF: must be wallet owner\");\n        _;\n    }\n\n    /**\n     * @notice Throws if the sender is not an authorised feature of the target wallet.\n     */\n    modifier onlyWalletFeature(address _wallet) {\n        require(versionManager.isFeatureAuthorised(_wallet, msg.sender), \"BF: must be a wallet feature\");\n        _;\n    }\n\n    /**\n     * @notice Throws if the sender is not the owner of the target wallet or the feature itself.\n     */\n    modifier onlyWalletOwnerOrFeature(address _wallet) {\n        // Wrapping in an internal method reduces deployment cost by avoiding duplication of inlined code\n        verifyOwnerOrAuthorisedFeature(_wallet, msg.sender);\n        _;\n    }\n\n    constructor(\n        ILockStorage _lockStorage,\n        IVersionManager _versionManager,\n        bytes32 _name\n    ) public {\n        lockStorage = _lockStorage;\n        versionManager = _versionManager;\n        emit FeatureCreated(_name);\n    }\n\n    /**\n    * @inheritdoc IFeature\n    */\n    function recoverToken(address _token) external virtual override {\n        uint total = ERC20(_token).balanceOf(address(this));\n        _token.call(abi.encodeWithSelector(ERC20(_token).transfer.selector, address(versionManager), total));\n    }\n\n    /**\n     * @notice Inits the feature for a wallet by doing nothing.\n     * @dev !! Overriding methods need make sure `init()` can only be called by the VersionManager !!\n     * @param _wallet The wallet.\n     */\n    function init(address _wallet) external virtual override  {}\n\n    /**\n     * @inheritdoc IFeature\n     */\n    function getRequiredSignatures(address, bytes calldata) external virtual view override returns (uint256, OwnerSignature) {\n        revert(\"BF: disabled method\");\n    }\n\n    /**\n     * @inheritdoc IFeature\n     */\n    function getStaticCallSignatures() external virtual override view returns (bytes4[] memory _sigs) {}\n\n    /**\n     * @inheritdoc IFeature\n     */\n    function isFeatureAuthorisedInVersionManager(address _wallet, address _feature) public override view returns (bool) {\n        return versionManager.isFeatureAuthorised(_wallet, _feature);\n    }\n\n    /**\n    * @notice Checks that the wallet address provided as the first parameter of _data matches _wallet\n    * @return false if the addresses are different.\n    */\n    function verifyData(address _wallet, bytes calldata _data) internal pure returns (bool) {\n        require(_data.length \u003e= 36, \"RM: Invalid dataWallet\");\n        address dataWallet = abi.decode(_data[4:], (address));\n        return dataWallet == _wallet;\n    }\n    \n     /**\n     * @notice Helper method to check if an address is the owner of a target wallet.\n     * @param _wallet The target wallet.\n     * @param _addr The address.\n     */\n    function isOwner(address _wallet, address _addr) internal view returns (bool) {\n        return IWallet(_wallet).owner() == _addr;\n    }\n\n    /**\n     * @notice Verify that the caller is an authorised feature or the wallet owner.\n     * @param _wallet The target wallet.\n     * @param _sender The caller.\n     */\n    function verifyOwnerOrAuthorisedFeature(address _wallet, address _sender) internal view {\n        require(isFeatureAuthorisedInVersionManager(_wallet, _sender) || isOwner(_wallet, _sender), \"BF: must be owner or feature\");\n    }\n\n    /**\n     * @notice Helper method to invoke a wallet.\n     * @param _wallet The target wallet.\n     * @param _to The target address for the transaction.\n     * @param _value The value of the transaction.\n     * @param _data The data of the transaction.\n     */\n    function invokeWallet(address _wallet, address _to, uint256 _value, bytes memory _data)\n        internal\n        returns (bytes memory _res) \n    {\n        _res = versionManager.checkAuthorisedFeatureAndInvokeWallet(_wallet, _to, _value, _data);\n    }\n\n}"},"ERC20.sol":{"content":"pragma solidity \u003e=0.5.4 \u003c0.7.0;\n\n/**\n * ERC20 contract interface.\n */\ninterface ERC20 {\n    function totalSupply() external view returns (uint);\n    function decimals() external view returns (uint);\n    function balanceOf(address tokenOwner) external view returns (uint balance);\n    function allowance(address tokenOwner, address spender) external view returns (uint remaining);\n    function transfer(address to, uint tokens) external returns (bool success);\n    function approve(address spender, uint tokens) external returns (bool success);\n    function transferFrom(address from, address to, uint tokens) external returns (bool success);\n}"},"IFeature.sol":{"content":"// Copyright (C) 2018  Argent Labs Ltd. \u003chttps://argent.xyz\u003e\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity \u003e=0.5.4 \u003c0.7.0;\n\n/**\n * @title IFeature\n * @notice Interface for a Feature.\n * @author Julien Niset - \u003cjulien@argent.xyz\u003e, Olivier VDB - \u003colivier@argent.xyz\u003e\n */\ninterface IFeature {\n\n    enum OwnerSignature {\n        Anyone,             // Anyone\n        Required,           // Owner required\n        Optional,           // Owner and/or guardians\n        Disallowed          // guardians only\n    }\n\n    /**\n    * @notice Utility method to recover any ERC20 token that was sent to the Feature by mistake.\n    * @param _token The token to recover.\n    */\n    function recoverToken(address _token) external;\n\n    /**\n     * @notice Inits a Feature for a wallet by e.g. setting some wallet specific parameters in storage.\n     * @param _wallet The wallet.\n     */\n    function init(address _wallet) external;\n\n    /**\n     * @notice Helper method to check if an address is an authorised feature of a target wallet.\n     * @param _wallet The target wallet.\n     * @param _feature The address.\n     */\n    function isFeatureAuthorisedInVersionManager(address _wallet, address _feature) external view returns (bool);\n\n    /**\n    * @notice Gets the number of valid signatures that must be provided to execute a\n    * specific relayed transaction.\n    * @param _wallet The target wallet.\n    * @param _data The data of the relayed transaction.\n    * @return The number of required signatures and the wallet owner signature requirement.\n    */\n    function getRequiredSignatures(address _wallet, bytes calldata _data) external view returns (uint256, OwnerSignature);\n\n    /**\n    * @notice Gets the list of static call signatures that this feature responds to on behalf of wallets\n    */\n    function getStaticCallSignatures() external view returns (bytes4[] memory);\n}"},"ILimitStorage.sol":{"content":"// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.6.12;\npragma experimental ABIEncoderV2;\n\n/**\n * @title ILimitStorage\n * @notice LimitStorage interface\n */\ninterface ILimitStorage {\n\n    struct Limit {\n        // the current limit\n        uint128 current;\n        // the pending limit if any\n        uint128 pending;\n        // when the pending limit becomes the current limit\n        uint64 changeAfter;\n    }\n\n    struct DailySpent {\n        // The amount already spent during the current period\n        uint128 alreadySpent;\n        // The end of the current period\n        uint64 periodEnd;\n    }\n\n    function setLimit(address _wallet, Limit memory _limit) external;\n\n    function getLimit(address _wallet) external view returns (Limit memory _limit);\n\n    function setDailySpent(address _wallet, DailySpent memory _dailySpent) external;\n\n    function getDailySpent(address _wallet) external view returns (DailySpent memory _dailySpent);\n\n    function setLimitAndDailySpent(address _wallet, Limit memory _limit, DailySpent memory _dailySpent) external;\n\n    function getLimitAndDailySpent(address _wallet) external view returns (Limit memory _limit, DailySpent memory _dailySpent);\n}"},"ILockStorage.sol":{"content":"// Copyright (C) 2018  Argent Labs Ltd. \u003chttps://argent.xyz\u003e\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity \u003e=0.5.4 \u003c0.7.0;\n\ninterface ILockStorage {\n    function isLocked(address _wallet) external view returns (bool);\n\n    function getLock(address _wallet) external view returns (uint256);\n\n    function getLocker(address _wallet) external view returns (address);\n\n    function setLock(address _wallet, address _locker, uint256 _releaseAfter) external;\n}"},"IModuleRegistry.sol":{"content":"// Copyright (C) 2020  Argent Labs Ltd. \u003chttps://argent.xyz\u003e\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity \u003e=0.5.4 \u003c0.7.0;\n\n/**\n * @title IModuleRegistry\n * @notice Interface for the registry of authorised modules.\n */\ninterface IModuleRegistry {\n    function registerModule(address _module, bytes32 _name) external;\n\n    function deregisterModule(address _module) external;\n\n    function registerUpgrader(address _upgrader, bytes32 _name) external;\n\n    function deregisterUpgrader(address _upgrader) external;\n\n    function recoverToken(address _token) external;\n\n    function moduleInfo(address _module) external view returns (bytes32);\n\n    function upgraderInfo(address _upgrader) external view returns (bytes32);\n\n    function isRegisteredModule(address _module) external view returns (bool);\n\n    function isRegisteredModule(address[] calldata _modules) external view returns (bool);\n\n    function isRegisteredUpgrader(address _upgrader) external view returns (bool);\n}"},"ITokenPriceRegistry.sol":{"content":"// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.6.12;\n\n/**\n * @title ITokenPriceRegistry\n * @notice TokenPriceRegistry interface\n */\ninterface ITokenPriceRegistry {\n    function getTokenPrice(address _token) external view returns (uint184 _price);\n    function isTokenTradable(address _token) external view returns (bool _isTradable);\n}"},"IVersionManager.sol":{"content":"// Copyright (C) 2018  Argent Labs Ltd. \u003chttps://argent.xyz\u003e\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity \u003e=0.5.4 \u003c0.7.0;\npragma experimental ABIEncoderV2;\n\nimport \"./ILimitStorage.sol\";\n\n/**\n * @title IVersionManager\n * @notice Interface for the VersionManager module.\n * @author Olivier VDB - \u003colivier@argent.xyz\u003e\n */\ninterface IVersionManager {\n    /**\n     * @notice Returns true if the feature is authorised for the wallet\n     * @param _wallet The target wallet.\n     * @param _feature The feature.\n     */\n    function isFeatureAuthorised(address _wallet, address _feature) external view returns (bool);\n\n    /**\n     * @notice Lets a feature (caller) invoke a wallet.\n     * @param _wallet The target wallet.\n     * @param _to The target address for the transaction.\n     * @param _value The value of the transaction.\n     * @param _data The data of the transaction.\n     */\n    function checkAuthorisedFeatureAndInvokeWallet(\n        address _wallet,\n        address _to,\n        uint256 _value,\n        bytes calldata _data\n    ) external returns (bytes memory _res);\n\n    /* ******* Backward Compatibility with old Storages and BaseWallet *************** */\n\n    /**\n     * @notice Sets a new owner for the wallet.\n     * @param _newOwner The new owner.\n     */\n    function setOwner(address _wallet, address _newOwner) external;\n\n    /**\n     * @notice Lets a feature write data to a storage contract.\n     * @param _wallet The target wallet.\n     * @param _storage The storage contract.\n     * @param _data The data of the call\n     */\n    function invokeStorage(address _wallet, address _storage, bytes calldata _data) external;\n\n    /**\n     * @notice Upgrade a wallet to a new version.\n     * @param _wallet the wallet to upgrade\n     * @param _toVersion the new version\n     */\n    function upgradeWallet(address _wallet, uint256 _toVersion) external;\n \n}"},"IWallet.sol":{"content":"// Copyright (C) 2018  Argent Labs Ltd. \u003chttps://argent.xyz\u003e\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity \u003e=0.5.4 \u003c0.7.0;\n\n/**\n * @title IWallet\n * @notice Interface for the BaseWallet\n */\ninterface IWallet {\n    /**\n     * @notice Returns the wallet owner.\n     * @return The wallet owner address.\n     */\n    function owner() external view returns (address);\n\n    /**\n     * @notice Returns the number of authorised modules.\n     * @return The number of authorised modules.\n     */\n    function modules() external view returns (uint);\n\n    /**\n     * @notice Sets a new owner for the wallet.\n     * @param _newOwner The new owner.\n     */\n    function setOwner(address _newOwner) external;\n\n    /**\n     * @notice Checks if a module is authorised on the wallet.\n     * @param _module The module address to check.\n     * @return `true` if the module is authorised, otherwise `false`.\n     */\n    function authorised(address _module) external view returns (bool);\n\n    /**\n     * @notice Returns the module responsible for a static call redirection.\n     * @param _sig The signature of the static call.\n     * @return the module doing the redirection\n     */\n    function enabled(bytes4 _sig) external view returns (address);\n\n    /**\n     * @notice Enables/Disables a module.\n     * @param _module The target module.\n     * @param _value Set to `true` to authorise the module.\n     */\n    function authoriseModule(address _module, bool _value) external;\n\n    /**\n    * @notice Enables a static method by specifying the target module to which the call must be delegated.\n    * @param _module The target module.\n    * @param _method The static method signature.\n    */\n    function enableStaticCall(address _module, bytes4 _method) external;\n}"},"NftTransfer.sol":{"content":"// Copyright (C) 2018  Argent Labs Ltd. \u003chttps://argent.xyz\u003e\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003chttp://www.gnu.org/licenses/\u003e.\n\n// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.6.12;\n\nimport \"./BaseFeature.sol\";\nimport \"./ITokenPriceRegistry.sol\";\n\n/**\n * @title NftTransfer\n * @notice Module to transfer NFTs (ERC721),\n * @author Olivier VDB - \u003colivier@argent.xyz\u003e\n */\ncontract NftTransfer is BaseFeature{\n\n    bytes32 constant NAME = \"NftTransfer\";\n\n    // Equals to `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`\n    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;\n\n    // The address of the CryptoKitties contract\n    address public ckAddress;\n    // The token price registry\n    ITokenPriceRegistry public tokenPriceRegistry;\n\n    // *************** Events *************************** //\n\n    event NonFungibleTransfer(address indexed wallet, address indexed nftContract, uint256 indexed tokenId, address to, bytes data);\n\n    // *************** Constructor ********************** //\n\n    constructor(\n        ILockStorage _lockStorage,\n        ITokenPriceRegistry _tokenPriceRegistry,\n        IVersionManager _versionManager,\n        address _ckAddress\n    )\n        BaseFeature(_lockStorage, _versionManager, NAME)\n        public\n    {\n        ckAddress = _ckAddress;\n        tokenPriceRegistry = _tokenPriceRegistry;\n    }\n\n    // *************** External/Public Functions ********************* //\n    /**\n     * @inheritdoc IFeature\n     */\n    function getRequiredSignatures(address, bytes calldata) external view override returns (uint256, OwnerSignature) {\n        return (1, OwnerSignature.Required);\n    }\n\n    /**\n     * @inheritdoc IFeature\n     */\n    function getStaticCallSignatures() external virtual override view returns (bytes4[] memory _sigs) {\n        _sigs = new bytes4[](1);\n        _sigs[0] = ERC721_RECEIVED;\n    }\n\n    /**\n     * @notice Handle the receipt of an NFT\n     * @notice An ERC721 smart contract calls this function on the recipient contract\n     * after a `safeTransfer`. If the recipient is a BaseWallet, the call to onERC721Received\n     * will be forwarded to the method onERC721Received of the present module.\n     * @return bytes4 `bytes4(keccak256(\"onERC721Received(address,address,uint256,bytes)\"))`\n     */\n    function onERC721Received(\n        address /* operator */,\n        address /* from */,\n        uint256 /* tokenId */,\n        bytes calldata /* data*/\n    )\n        external\n        returns (bytes4)\n    {\n        return ERC721_RECEIVED;\n    }\n\n    /**\n    * @notice Lets the owner transfer NFTs from a wallet.\n    * @param _wallet The target wallet.\n    * @param _nftContract The ERC721 address.\n    * @param _to The recipient.\n    * @param _tokenId The NFT id\n    * @param _safe Whether to execute a safe transfer or not\n    * @param _data The data to pass with the transfer.\n    */\n    function transferNFT(\n        address _wallet,\n        address _nftContract,\n        address _to,\n        uint256 _tokenId,\n        bool _safe,\n        bytes calldata _data\n    )\n        external\n        onlyWalletOwnerOrFeature(_wallet)\n        onlyWhenUnlocked(_wallet)\n    {\n        bytes memory methodData;\n        if (_nftContract == ckAddress) {\n            methodData = abi.encodeWithSignature(\"transfer(address,uint256)\", _to, _tokenId);\n        } else {\n           if (_safe) {\n               methodData = abi.encodeWithSignature(\n                   \"safeTransferFrom(address,address,uint256,bytes)\", _wallet, _to, _tokenId, _data);\n           } else {\n               require(!coveredByDailyLimit(_nftContract), \"NT: Forbidden ERC20 contract\");\n               methodData = abi.encodeWithSignature(\n                   \"transferFrom(address,address,uint256)\", _wallet, _to, _tokenId);\n           }\n        }\n        invokeWallet(_wallet, _nftContract, 0, methodData);\n        emit NonFungibleTransfer(_wallet, _nftContract, _tokenId, _to, _data);\n    }\n\n    // *************** Internal Functions ********************* //\n\n    /**\n    * @notice Returns true if the contract is a supported ERC20.\n    * @param _contract The address of the contract.\n     */\n    function coveredByDailyLimit(address _contract) internal view returns (bool) {\n        return tokenPriceRegistry.getTokenPrice(_contract) \u003e 0;\n    }\n\n}"},"SafeMath.sol":{"content":"pragma solidity ^0.6.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n"}}