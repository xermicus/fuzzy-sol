{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}"},"CRDAirdrop.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\r\n\r\npragma solidity ^0.8.4;\r\n\r\nimport \"./Ownable.sol\";\r\n\r\ninterface IERC20 { \r\n   function transfer(address recipient, uint256 amount) external returns (bool); \r\n   function balanceOf(address account) external view returns (uint256);\r\n} \r\n\r\ncontract CRDNetworkAirdropV1 is Ownable {\r\n  \r\n    mapping (address =\u003e bool) private isAdmin;\r\n    mapping (address =\u003e bool) private addressRecord;\r\n    \r\n    address public tokenAddress;\r\n    uint public rewardAmount;\r\n    \r\n    constructor(address _tokenAddress, uint _rewardAmount) Ownable() {\r\n        tokenAddress = _tokenAddress;\r\n        rewardAmount = _rewardAmount;\r\n        isAdmin[_msgSender()] = true;\r\n    }\r\n\r\n    modifier onlyAdmin() {\r\n        require(isAdmin[msg.sender]);\r\n        _;\r\n    }\r\n    \r\n    function claimReward() public { \r\n        require (addressRecord[msg.sender]  == true);  \r\n        IERC20(tokenAddress).transfer(msg.sender, rewardAmount); \r\n        addressRecord[msg.sender] = false; \r\n    }\r\n    \r\n    function setReward(uint _rewardAmount) public onlyAdmin { \r\n        rewardAmount = _rewardAmount; \r\n    }\r\n    \r\n    function setToken(address  _tokenAddress) public onlyAdmin { \r\n        tokenAddress = _tokenAddress; \r\n    }\r\n\r\n    function setAccounts(address[] memory _records) public onlyAdmin { \r\n        for(uint i=0; i\u003c _records.length; i++){\r\n           addressRecord[_records[i]] = true;\r\n        } \r\n    }\r\n    \r\n    function checkStatus(address  _address) public view returns(bool, uint) { \r\n        return (addressRecord[_address], rewardAmount);\r\n    }\r\n    \r\n    function transferToken(  uint _amount) public  onlyAdmin returns (bool){  \r\n        IERC20(tokenAddress).transfer(msg.sender, _amount);\r\n        return true;\r\n    }  \r\n       \r\n}\r\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor() {\r\n        _setOwner(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _setOwner(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        _setOwner(newOwner);\r\n    }\r\n\r\n    function _setOwner(address newOwner) private {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}"}}