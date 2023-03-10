{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 999999
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
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "contracts/RareRedirect.sol": {
      "content": "/*\n *\n *\n                                                             \n                                                             \n                                                             \n888d888 8888b.  888d888 .d88b.                               \n888P\"      \"88b 888P\"  d8P  Y8b                              \n888    .d888888 888    88888888                              \n888    888  888 888    Y8b.                                  \n888    \"Y888888 888     \"Y8888                               \n                                                             \n                                                             \n                                                             \n                     888 d8b                          888    \n                     888 Y8P                          888    \n                     888                              888    \n888d888 .d88b.   .d88888 888 888d888 .d88b.   .d8888b 888888 \n888P\"  d8P  Y8b d88\" 888 888 888P\"  d8P  Y8b d88P\"    888    \n888    88888888 888  888 888 888    88888888 888      888    \n888    Y8b.     Y88b 888 888 888    Y8b.     Y88b.    Y88b.  \n888     \"Y8888   \"Y88888 888 888     \"Y8888   \"Y8888P  \"Y888 \n                                                             \n\n\n This contract is unaudited. It's basically a ponzi.\n It's worse than a ponzi. It's definitely not \"trustless\".\n DNS is centralized. I'll change the URL if I deem it\n harmful/illegal/etc. No guarantees, no refunds.                                                          \n\n\n\n *\n *\n */\n\n// SPDX-License-Identifier: MIT\npragma solidity 0.8.5;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\n\ncontract RareRedirect is Ownable {\n    // minimum price required to change the `currentUrl`\n    uint256 public priceFloor;\n    // current URL where site will be redirected\n    string currentUrl = \"\";\n\n    event redirectChange(string currentURL, uint256 priceFloor);\n\n    function getUrl() public view returns (string memory) {\n        return currentUrl;\n    }\n\n    function setUrlPayable(string memory newRedirectUrl)\n        external\n        payable\n        returns (string memory)\n    {\n        require(\n            msg.value > priceFloor,\n            \"Value must be greater than priceFloor\"\n        );\n        currentUrl = newRedirectUrl;\n        priceFloor = msg.value;\n\n        emit redirectChange(currentUrl, priceFloor);\n        return currentUrl;\n    }\n\n    function setUrlForOwner(string memory ownerUrl)\n        public\n        onlyOwner\n        returns (string memory)\n    {\n        currentUrl = ownerUrl;\n\n        emit redirectChange(currentUrl, priceFloor);\n        return currentUrl;\n    }\n\n    function getPriceFloor() public view returns (uint256) {\n        return priceFloor;\n    }\n\n    function withdrawAll() external onlyOwner {\n        payable(owner()).transfer(address(this).balance);\n    }\n}\n"
    }
  }
}}