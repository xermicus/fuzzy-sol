{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 1000000
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
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface AggregatorV3Interface {\n\n  function decimals()\n    external\n    view\n    returns (\n      uint8\n    );\n\n  function description()\n    external\n    view\n    returns (\n      string memory\n    );\n\n  function version()\n    external\n    view\n    returns (\n      uint256\n    );\n\n  // getRoundData and latestRoundData should both raise \"No data present\"\n  // if they do not have data to report, instead of returning unset values\n  // which could be misinterpreted as actual reported values.\n  function getRoundData(\n    uint80 _roundId\n  )\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n  function latestRoundData()\n    external\n    view\n    returns (\n      uint80 roundId,\n      int256 answer,\n      uint256 startedAt,\n      uint256 updatedAt,\n      uint80 answeredInRound\n    );\n\n}\n"
    },
    "contracts/interfaces/IOracle.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\n/// @title IOracle\n/// @author Angle Core Team\n/// @notice Interface for Angle's oracle contracts reading oracle rates from both UniswapV3 and Chainlink\n/// from just UniswapV3 or from just Chainlink\ninterface IOracle {\n    function read() external view returns (uint256);\n\n    function readAll() external view returns (uint256 lowerRate, uint256 upperRate);\n\n    function readLower() external view returns (uint256);\n\n    function readUpper() external view returns (uint256);\n\n    function readQuote(uint256 baseAmount) external view returns (uint256);\n\n    function readQuoteLower(uint256 baseAmount) external view returns (uint256);\n\n    function inBase() external view returns (uint256);\n}\n"
    },
    "contracts/oracle/OracleAbstract.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"../interfaces/IOracle.sol\";\n\n/// @title OracleAbstract\n/// @author Angle Core Team\n/// @notice Abstract Oracle contract that contains some of the functions that are used across all oracle contracts\n/// @dev This is the most generic form of oracle contract\n/// @dev A rate gives the price of the out-currency with respect to the in-currency in base `BASE`. For instance\n/// if the out-currency is ETH worth 1000 USD, then the rate ETH-USD is 10**21\nabstract contract OracleAbstract is IOracle {\n    /// @notice Base used for computation\n    uint256 public constant BASE = 10**18;\n    /// @notice Unit of the in-currency\n    uint256 public override inBase;\n    /// @notice Description of the assets concerned by the oracle and the price outputted\n    bytes32 public description;\n\n    /// @notice Reads one of the rates from the circuits given\n    /// @return rate The current rate between the in-currency and out-currency\n    /// @dev By default if the oracle involves a Uniswap price and a Chainlink price\n    /// this function will return the Uniswap price\n    /// @dev The rate returned is expressed with base `BASE` (and not the base of the out-currency)\n    function read() external view virtual override returns (uint256 rate);\n\n    /// @notice Read rates from the circuit of both Uniswap and Chainlink if there are both circuits\n    /// else returns twice the same price\n    /// @return Return all available rates (Chainlink and Uniswap) with the lowest rate returned first.\n    /// @dev The rate returned is expressed with base `BASE` (and not the base of the out-currency)\n    function readAll() external view override returns (uint256, uint256) {\n        return _readAll(inBase);\n    }\n\n    /// @notice Reads rates from the circuit of both Uniswap and Chainlink if there are both circuits\n    /// and returns either the highest of both rates or the lowest\n    /// @return rate The lower rate between Chainlink and Uniswap\n    /// @dev If there is only one rate computed in an oracle contract, then the only rate is returned\n    /// regardless of the value of the `lower` parameter\n    /// @dev The rate returned is expressed with base `BASE` (and not the base of the out-currency)\n    function readLower() external view override returns (uint256 rate) {\n        (rate, ) = _readAll(inBase);\n    }\n\n    /// @notice Reads rates from the circuit of both Uniswap and Chainlink if there are both circuits\n    /// and returns either the highest of both rates or the lowest\n    /// @return rate The upper rate between Chainlink and Uniswap\n    /// @dev If there is only one rate computed in an oracle contract, then the only rate is returned\n    /// regardless of the value of the `lower` parameter\n    /// @dev The rate returned is expressed with base `BASE` (and not the base of the out-currency)\n    function readUpper() external view override returns (uint256 rate) {\n        (, rate) = _readAll(inBase);\n    }\n\n    /// @notice Converts an in-currency quote amount to out-currency using one of the rates available in the oracle\n    /// contract\n    /// @param quoteAmount Amount (in the input collateral) to be converted to be converted in out-currency\n    /// @return Quote amount in out-currency from the base amount in in-currency\n    /// @dev Like in the read function, if the oracle involves a Uniswap and a Chainlink price, this function\n    /// will use the Uniswap price to compute the out quoteAmount\n    /// @dev The rate returned is expressed with base `BASE` (and not the base of the out-currency)\n    function readQuote(uint256 quoteAmount) external view virtual override returns (uint256);\n\n    /// @notice Returns the lowest quote amount between Uniswap and Chainlink circuits (if possible). If the oracle\n    /// contract only involves a single feed, then this returns the value of this feed\n    /// @param quoteAmount Amount (in the input collateral) to be converted\n    /// @return The lowest quote amount from the quote amount in in-currency\n    /// @dev The rate returned is expressed with base `BASE` (and not the base of the out-currency)\n    function readQuoteLower(uint256 quoteAmount) external view override returns (uint256) {\n        (uint256 quoteSmall, ) = _readAll(quoteAmount);\n        return quoteSmall;\n    }\n\n    /// @notice Returns Uniswap and Chainlink values (with the first one being the smallest one) or twice the same value\n    /// if just Uniswap or just Chainlink is used\n    /// @param quoteAmount Amount expressed in the in-currency base.\n    /// @dev If `quoteAmount` is `inBase`, rates are returned\n    /// @return The first return value is the lowest value and the second parameter is the highest\n    /// @dev The rate returned is expressed with base `BASE` (and not the base of the out-currency)\n    function _readAll(uint256 quoteAmount) internal view virtual returns (uint256, uint256) {}\n}\n"
    },
    "contracts/oracle/OracleChainlinkSingle.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\n// contracts/oracle/OracleChainlinkSingle.sol\npragma solidity ^0.8.7;\n\nimport \"./OracleAbstract.sol\";\nimport \"./modules/ModuleChainlinkSingle.sol\";\n\n/// @title OracleChainlinkSingle\n/// @author Angle Core Team\n/// @notice Oracle contract, one contract is deployed per collateral/stablecoin pair\n/// @dev This contract concerns an oracle that only uses Chainlink and a single pool\n/// @dev This is mainly going to be the contract used for the USD/EUR pool (or for other fiat currencies)\n/// @dev Like all oracle contracts, this contract is an instance of `OracleAstract` that contains some\n/// base functions\ncontract OracleChainlinkSingle is OracleAbstract, ModuleChainlinkSingle {\n    /// @notice Constructor for the oracle using a single Chainlink pool\n    /// @param _poolChainlink Chainlink pool address\n    /// @param _isChainlinkMultiplied Whether we should multiply or divide by the Chainlink rate the\n    /// in-currency amount to get the out-currency amount\n    /// @param _inBase Number of units of the in-currency\n    /// @param _description Description of the assets concerned by the oracle\n    constructor(\n        address _poolChainlink,\n        uint8 _isChainlinkMultiplied,\n        uint256 _inBase,\n        bytes32 _description\n    ) ModuleChainlinkSingle(_poolChainlink, _isChainlinkMultiplied) {\n        inBase = _inBase;\n        description = _description;\n    }\n\n    /// @notice Reads the rate from the Chainlink feed\n    /// @return rate The current rate between the in-currency and out-currency\n    function read() external view override returns (uint256 rate) {\n        (rate, ) = _quoteChainlink(BASE);\n    }\n\n    /// @notice Converts an in-currency quote amount to out-currency using Chainlink's feed\n    /// @param quoteAmount Amount (in the input collateral) to be converted in out-currency\n    /// @return Quote amount in out-currency from the base amount in in-currency\n    /// @dev The amount returned is expressed with base `BASE` (and not the base of the out-currency)\n    function readQuote(uint256 quoteAmount) external view override returns (uint256) {\n        return _readQuote(quoteAmount);\n    }\n\n    /// @notice Returns Chainlink quote value twice\n    /// @param quoteAmount Amount expressed in the in-currency base.\n    /// @dev If quoteAmount is `inBase`, rates are returned\n    /// @return The two return values are similar in this case\n    /// @dev The amount returned is expressed with base `BASE` (and not the base of the out-currency)\n    function _readAll(uint256 quoteAmount) internal view override returns (uint256, uint256) {\n        uint256 quote = _readQuote(quoteAmount);\n        return (quote, quote);\n    }\n\n    /// @notice Internal function to convert an in-currency quote amount to out-currency using Chainlink's feed\n    /// @param quoteAmount Amount (in the input collateral) to be converted\n    /// @dev The amount returned is expressed with base `BASE` (and not the base of the out-currency)\n    function _readQuote(uint256 quoteAmount) internal view returns (uint256) {\n        quoteAmount = (quoteAmount * BASE) / inBase;\n        (quoteAmount, ) = _quoteChainlink(quoteAmount);\n        // We return only rates with base BASE\n        return quoteAmount;\n    }\n}\n"
    },
    "contracts/oracle/modules/ModuleChainlinkSingle.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"../utils/ChainlinkUtils.sol\";\n\n/// @title ModuleChainlinkSingle\n/// @author Angle Core Team\n/// @notice Module Contract that is going to be used to help compute Chainlink prices\n/// @dev This contract will help for an oracle using a single Chainlink price\n/// @dev An oracle using Chainlink is either going to be a `ModuleChainlinkSingle` or a `ModuleChainlinkMulti`\nabstract contract ModuleChainlinkSingle is ChainlinkUtils {\n    /// @notice Chainlink pool to look for in the contract\n    AggregatorV3Interface public immutable poolChainlink;\n    /// @notice Whether the rate computed using the Chainlink pool should be multiplied to the quote amount or not\n    uint8 public immutable isChainlinkMultiplied;\n    /// @notice Decimals for each Chainlink pairs\n    uint8 public immutable chainlinkDecimals;\n\n    /// @notice Constructor for an oracle using only a single Chainlink\n    /// @param _poolChainlink Chainlink pool address\n    /// @param _isChainlinkMultiplied Whether we should multiply or divide the quote amount by the rate\n    constructor(address _poolChainlink, uint8 _isChainlinkMultiplied) {\n        require(_poolChainlink != address(0), \"105\");\n        poolChainlink = AggregatorV3Interface(_poolChainlink);\n        chainlinkDecimals = AggregatorV3Interface(_poolChainlink).decimals();\n        isChainlinkMultiplied = _isChainlinkMultiplied;\n    }\n\n    /// @notice Reads oracle price using a single Chainlink pool\n    /// @param quoteAmount Amount expressed with base decimal\n    /// @dev If `quoteAmount` is base, the output is the oracle rate\n    function _quoteChainlink(uint256 quoteAmount) internal view returns (uint256, uint256) {\n        // No need for a for loop here as there is only a single pool we are looking at\n        return _readChainlinkFeed(quoteAmount, poolChainlink, isChainlinkMultiplied, chainlinkDecimals, 0);\n    }\n}\n"
    },
    "contracts/oracle/utils/ChainlinkUtils.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.7;\n\nimport \"@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol\";\n\n/// @title ChainlinkUtils\n/// @author Angle Core Team\n/// @notice Utility contract that is used across the different module contracts using Chainlink\nabstract contract ChainlinkUtils {\n    /// @notice Reads a Chainlink feed using a quote amount and converts the quote amount to\n    /// the out-currency\n    /// @param quoteAmount The amount for which to compute the price expressed with base decimal\n    /// @param feed Chainlink feed to query\n    /// @param multiplied Whether the ratio outputted by Chainlink should be multiplied or divided\n    /// to the `quoteAmount`\n    /// @param decimals Number of decimals of the corresponding Chainlink pair\n    /// @param castedRatio Whether a previous rate has already been computed for this feed\n    /// This is mostly used in the `_changeUniswapNotFinal` function of the oracles\n    /// @return The `quoteAmount` converted in out-currency (computed using the second return value)\n    /// @return The value obtained with the Chainlink feed queried casted to uint\n    function _readChainlinkFeed(\n        uint256 quoteAmount,\n        AggregatorV3Interface feed,\n        uint8 multiplied,\n        uint256 decimals,\n        uint256 castedRatio\n    ) internal view returns (uint256, uint256) {\n        if (castedRatio == 0) {\n            (, int256 ratio, , , ) = feed.latestRoundData();\n            require(ratio > 0, \"100\");\n            castedRatio = uint256(ratio);\n        }\n        // Checking whether we should multiply or divide by the ratio computed\n        if (multiplied == 1) quoteAmount = (quoteAmount * castedRatio) / (10**decimals);\n        else quoteAmount = (quoteAmount * (10**decimals)) / castedRatio;\n        return (quoteAmount, castedRatio);\n    }\n}\n"
    }
  }
}}