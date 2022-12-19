{{
  "language": "Solidity",
  "sources": {
    "./contracts/oracles/CurveLPOracle.sol": {
      "content": "// SPDX-License-Identifier: bsl-1.1\n\n/*\n  Copyright 2020 Unit Protocol: Artem Zakharov (az@unit.xyz).\n*/\npragma solidity 0.7.6;\n\nimport \"../interfaces/IOracleUsd.sol\";\nimport \"../interfaces/IOracleEth.sol\";\nimport \"../helpers/ERC20Like.sol\";\nimport \"../helpers/SafeMath.sol\";\nimport \"../interfaces/IOracleRegistry.sol\";\nimport \"../interfaces/ICurveProvider.sol\";\nimport \"../interfaces/ICurveRegistry.sol\";\nimport \"../interfaces/ICurvePool.sol\";\n\n/**\n * @title CurveLPOracle\n * @dev Oracle to quote curve LP tokens\n **/\ncontract CurveLPOracle is IOracleUsd {\n    using SafeMath for uint;\n\n    uint public constant Q112 = 2 ** 112;\n    uint public constant PRECISION = 1e18;\n\n    // CurveProvider contract\n    ICurveProvider public immutable curveProvider;\n    // ChainlinkedOracle contract\n    IOracleRegistry public immutable oracleRegistry;\n\n    /**\n     * @param _curveProvider The address of the Curve Provider. Mainnet: 0x0000000022D53366457F9d5E68Ec105046FC4383\n     * @param _oracleRegistry The address of the OracleRegistry contract\n     **/\n    constructor(address _curveProvider, address _oracleRegistry) {\n        require(_curveProvider != address(0) && _oracleRegistry != address(0), \"Unit Protocol: ZERO_ADDRESS\");\n        curveProvider = ICurveProvider(_curveProvider);\n        oracleRegistry = IOracleRegistry(_oracleRegistry);\n    }\n\n    // returns Q112-encoded value\n    function assetToUsd(address asset, uint amount) public override view returns (uint) {\n        if (amount == 0) return 0;\n        ICurveRegistry cR = ICurveRegistry(curveProvider.get_registry());\n        ICurvePool cP = ICurvePool(cR.get_pool_from_lp_token(asset));\n        require(address(cP) != address(0), \"Unit Protocol: NOT_A_CURVE_LP\");\n        require(ERC20Like(asset).decimals() == uint8(18), \"Unit Protocol: INCORRECT_DECIMALS\");\n\n        uint coinsCount = cR.get_n_coins(address(cP))[0];\n        require(coinsCount != 0, \"Unit Protocol: CURVE_INCORRECT_COINS_COUNT\");\n\n        uint minCoinPrice_q112;\n\n        for (uint i = 0; i < coinsCount; i++) {\n            address _coin = cP.coins(i);\n            address oracle = oracleRegistry.oracleByAsset(_coin);\n            require(oracle != address(0), \"Unit Protocol: ORACLE_NOT_FOUND\");\n            uint _coinPrice_q112 = IOracleUsd(oracle).assetToUsd(_coin, 10 ** ERC20Like(_coin).decimals()) / 1 ether;\n            if (i == 0 || _coinPrice_q112 < minCoinPrice_q112) {\n                minCoinPrice_q112 = _coinPrice_q112;\n            }\n        }\n\n        uint price_q112 = cP.get_virtual_price().mul(minCoinPrice_q112).div(PRECISION);\n\n        return amount.mul(price_q112);\n    }\n\n}\n"
    },
    "./contracts/interfaces/IOracleUsd.sol": {
      "content": "interface IOracleUsd {\n\n    // returns Q112-encoded value\n    // returned value 10**18 * 2**112 is $1\n    function assetToUsd(address asset, uint amount) external view returns (uint);\n}"
    },
    "./contracts/interfaces/IOracleEth.sol": {
      "content": "interface IOracleEth {\n\n    // returns Q112-encoded value\n    // returned value 10**18 * 2**112 is 1 Ether\n    function assetToEth(address asset, uint amount) external view returns (uint);\n\n    // returns the value \"as is\"\n    function ethToUsd(uint amount) external view returns (uint);\n\n    // returns the value \"as is\"\n    function usdToEth(uint amount) external view returns (uint);\n}"
    },
    "./contracts/helpers/ERC20Like.sol": {
      "content": "// SPDX-License-Identifier: bsl-1.1\n\n/*\n  Copyright 2020 Unit Protocol: Artem Zakharov (az@unit.xyz).\n*/\npragma solidity 0.7.6;\n\n\ninterface ERC20Like {\n    function balanceOf(address) external view returns (uint);\n    function decimals() external view returns (uint8);\n    function transfer(address, uint256) external returns (bool);\n    function transferFrom(address, address, uint256) external returns (bool);\n    function totalSupply() external view returns (uint256);\n}\n"
    },
    "./contracts/helpers/SafeMath.sol": {
      "content": "// SPDX-License-Identifier: bsl-1.1\n\n/*\n  Copyright 2020 Unit Protocol: Artem Zakharov (az@unit.xyz).\n*/\npragma solidity 0.7.6;\n\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\nlibrary SafeMath {\n\n    /**\n    * @dev Multiplies two numbers, throws on overflow.\n    */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\n        if (a == 0) {\n            return 0;\n        }\n        c = a * b;\n        assert(c / a == b);\n        return c;\n    }\n\n    /**\n    * @dev Integer division of two numbers, truncating the quotient.\n    */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    /**\n    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\n    */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        assert(b <= a);\n        return a - b;\n    }\n\n    /**\n    * @dev Adds two numbers, throws on overflow.\n    */\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\n        c = a + b;\n        assert(c >= a);\n        return c;\n    }\n}\n"
    },
    "./contracts/interfaces/IOracleRegistry.sol": {
      "content": "pragma abicoder v2;\n\n\ninterface IOracleRegistry {\n\n    struct Oracle {\n        uint oracleType;\n        address oracleAddress;\n    }\n\n    function WETH (  ) external view returns ( address );\n    function getKeydonixOracleTypes (  ) external view returns ( uint256[] memory );\n    function getOracles (  ) external view returns ( Oracle[] memory foundOracles );\n    function keydonixOracleTypes ( uint256 ) external view returns ( uint256 );\n    function maxOracleType (  ) external view returns ( uint256 );\n    function oracleByAsset ( address asset ) external view returns ( address );\n    function oracleByType ( uint256 ) external view returns ( address );\n    function oracleTypeByAsset ( address ) external view returns ( uint256 );\n    function oracleTypeByOracle ( address ) external view returns ( uint256 );\n    function setKeydonixOracleTypes ( uint256[] memory _keydonixOracleTypes ) external;\n    function setOracle ( uint256 oracleType, address oracle ) external;\n    function setOracleTypeForAsset ( address asset, uint256 oracleType ) external;\n    function setOracleTypeForAssets ( address[] memory assets, uint256 oracleType ) external;\n    function unsetOracle ( uint256 oracleType ) external;\n    function unsetOracleForAsset ( address asset ) external;\n    function unsetOracleForAssets ( address[] memory assets ) external;\n    function vaultParameters (  ) external view returns ( address );\n}\n"
    },
    "./contracts/interfaces/ICurveProvider.sol": {
      "content": "interface ICurveProvider {\n    function get_registry() external view returns (address);\n}"
    },
    "./contracts/interfaces/ICurveRegistry.sol": {
      "content": "interface ICurveRegistry {\n    function get_pool_from_lp_token(address) external view returns (address);\n    function get_n_coins(address) external view returns (uint[2] memory);\n}"
    },
    "./contracts/interfaces/ICurvePool.sol": {
      "content": "interface ICurvePool {\n    function get_virtual_price() external view returns (uint);\n    function coins(uint) external view returns (address);\n}"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
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