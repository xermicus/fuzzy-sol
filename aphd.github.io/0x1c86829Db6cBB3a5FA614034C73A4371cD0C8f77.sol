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
    "contracts/formulas/SushiLPFormula.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"../lib/VotingPowerFormula.sol\";\n\n/**\n * @title SushiLPFormula\n * @dev Convert Sushi LP tokens to voting power\n */\ncontract SushiLPFormula is VotingPowerFormula {\n\n    /// @notice Current owner of this contract\n    address public owner;\n\n    /// @notice Conversion rate of token to voting power (measured in bips: 10,000 bips = 1%)\n    uint32 public conversionRate;\n\n    /// @notice Event emitted when the owner of the contract is updated\n    event ChangedOwner(address indexed oldOwner, address indexed newOwner);\n\n    /// @notice Event emitted when the conversion rate of the contract is changed\n    event ConversionRateChanged(uint32 oldRate, uint32 newRate);\n\n    /// @notice only owner can call function\n    modifier onlyOwner {\n        require(msg.sender == owner, \"not owner\");\n        _;\n    }\n\n    /**\n     * @notice Construct a new voting power formula contract\n     * @param _owner contract owner\n     * @param _cvrRate the conversion rate in bips\n     */\n    constructor(address _owner, uint32 _cvrRate) {\n        owner = _owner;\n        emit ChangedOwner(address(0), owner);\n\n        conversionRate = _cvrRate;\n        emit ConversionRateChanged(uint32(0), conversionRate);\n    }\n\n    /**\n     * @notice Convert token amount to voting power\n     * @param amount token amount\n     * @return voting power amount\n     */\n    function convertTokensToVotingPower(uint256 amount) external view override returns (uint256) {\n        return amount * conversionRate / 1000000;\n    }\n\n    /**\n     * @notice Set conversion rate of contract\n     * @param newConversionRate New conversion rate\n     */\n    function setConversionRate(uint32 newConversionRate) external onlyOwner {\n        emit ConversionRateChanged(conversionRate, newConversionRate);\n        conversionRate = newConversionRate;\n    }\n\n    /**\n     * @notice Change owner of contract\n     * @param newOwner New owner address\n     */\n    function changeOwner(address newOwner) external onlyOwner {\n        emit ChangedOwner(owner, newOwner);\n        owner = newOwner;\n    }\n}"
    },
    "contracts/lib/VotingPowerFormula.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nabstract contract VotingPowerFormula {\n   function convertTokensToVotingPower(uint256 amount) external view virtual returns (uint256);\n}"
    }
  }
}}