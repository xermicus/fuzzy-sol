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
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\nimport \"../utils/Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () internal {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0 <0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"
    },
    "contracts/ReferralRegistry.sol": {
      "content": "pragma solidity =0.6.6;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract ReferralRegistry is Ownable {\n    event ReferralAnchorCreated(address indexed user, address indexed referee);\n    event ReferralAnchorUpdated(address indexed user, address indexed referee);\n    event AnchorManagerUpdated(address account, bool isManager);\n\n    // stores addresses which are allowed to create new anchors\n    mapping(address => bool) public isAnchorManager;\n\n    // stores the address that referred a given user\n    mapping(address => address) public referralAnchor;\n\n    /// @dev create a new referral anchor on the registry\n    /// @param _user address of the user\n    /// @param _referee address wich referred the user\n    function createReferralAnchor(address _user, address _referee) external onlyAnchorManager {\n        require(referralAnchor[_user] == address(0), \"ReferralRegistry: ANCHOR_EXISTS\");\n        referralAnchor[_user] = _referee;\n        emit ReferralAnchorCreated(_user, _referee);\n    }\n\n    /// @dev allows admin to overwrite anchor\n    /// @param _user address of the user\n    /// @param _referee address wich referred the user\n    function updateReferralAnchor(address _user, address _referee) external onlyOwner {\n        referralAnchor[_user] = _referee;\n        emit ReferralAnchorUpdated(_user, _referee);\n    }\n\n    /// @dev allows admin to grant/remove anchor priviliges\n    /// @param _anchorManager address of the anchor manager\n    /// @param _isManager add or remove privileges\n    function updateAnchorManager(address _anchorManager, bool _isManager) external onlyOwner {\n        isAnchorManager[_anchorManager] = _isManager;\n        emit AnchorManagerUpdated(_anchorManager, _isManager);\n    }\n\n    function getUserReferee(address _user) external view returns (address) {\n        return referralAnchor[_user];\n    }\n\n    function hasUserReferee(address _user) external view returns (bool) {\n        return referralAnchor[_user] != address(0);\n    }\n\n    modifier onlyAnchorManager() {\n        require(isAnchorManager[msg.sender], \"ReferralRegistry: FORBIDDEN\");\n        _;\n    }\n}\n"
    }
  }
}}