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
    "contracts/TokenRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./interfaces/ITokenRegistry.sol\";\n\n/**\n * @title TokenRegistry\n * @dev Registry of tokens that Eden supports as stake for voting power \n * + their respective conversion formulas\n */\ncontract TokenRegistry is ITokenRegistry {\n\n    /// @notice Current owner of this contract\n    address public override owner;\n\n    /// @notice mapping of tokens to voting power calculation (formula) smart contract addresses\n    mapping (address => address) public override tokenFormulas;\n\n    /// @notice only owner can call function\n    modifier onlyOwner {\n        require(msg.sender == owner, \"not owner\");\n        _;\n    }\n\n    /**\n     * @notice Construct a new token registry contract\n     * @param _owner contract owner\n     * @param _tokens initially supported tokens\n     * @param _formulas formula contracts for initial tokens\n     */\n    constructor(\n        address _owner, \n        address[] memory _tokens, \n        address[] memory _formulas\n    ) {\n        require(_tokens.length == _formulas.length, \"TR::constructor: not same length\");\n        for (uint i = 0; i < _tokens.length; i++) {\n            tokenFormulas[_tokens[i]] = _formulas[i];\n            emit TokenFormulaUpdated(_tokens[i], _formulas[i]);\n        }\n        owner = _owner;\n        emit ChangedOwner(address(0), owner);\n    }\n\n    /**\n     * @notice Set conversion formula address for token\n     * @param token token for formula\n     * @param formula address of formula contract\n     */\n    function setTokenFormula(address token, address formula) external override onlyOwner {\n        tokenFormulas[token] = formula;\n        emit TokenFormulaUpdated(token, formula);\n    }\n\n    /**\n     * @notice Remove conversion formula address for token\n     * @param token token address to remove\n     */\n    function removeToken(address token) external override onlyOwner {\n        tokenFormulas[token] = address(0);\n        emit TokenRemoved(token);\n    }\n\n    /**\n     * @notice Change owner of token registry contract\n     * @param newOwner New owner address\n     */\n    function changeOwner(address newOwner) external override onlyOwner {\n        emit ChangedOwner(owner, newOwner);\n        owner = newOwner;\n    }\n}"
    },
    "contracts/interfaces/ITokenRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface ITokenRegistry {\n    function owner() external view returns (address);\n    function tokenFormulas(address) external view returns (address);\n    function setTokenFormula(address token, address formula) external;\n    function removeToken(address token) external;\n    function changeOwner(address newOwner) external;\n    event ChangedOwner(address indexed oldOwner, address indexed newOwner);\n    event TokenAdded(address indexed token, address indexed formula);\n    event TokenRemoved(address indexed token);\n    event TokenFormulaUpdated(address indexed token, address indexed formula);\n}"
    }
  }
}}