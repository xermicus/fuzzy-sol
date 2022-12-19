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
          "abi"
        ]
      }
    }
  },
  "sources": {
    "contracts/ArchiSwapOracle.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\r\npragma solidity ^0.8.2;\r\n\r\ninterface IArchiSwapPair {\r\n    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);\r\n    function price0CumulativeLast() external view returns (uint);\r\n    function price1CumulativeLast() external view returns (uint);\r\n    function token0() external view returns (address);\r\n    function token1() external view returns (address);\r\n}\r\n\r\ncontract ArchiSwapOracle {\r\n    address updater;\r\n    bool isEveryoneUpdate = false;\r\n    address immutable public pair;\r\n    Observation[65535] public observations;\r\n    uint16 public length;\r\n    uint constant periodSize = 1800;\r\n    uint Q112 = 2**112;\r\n    uint e10 = 10**18;\r\n\r\n    constructor(address _pair) {\r\n        pair = _pair;\r\n        updater = msg.sender;\r\n        (,,uint32 timestamp) = IArchiSwapPair(_pair).getReserves();\r\n        uint112 _price0CumulativeLast = uint112(IArchiSwapPair(_pair).price0CumulativeLast() * e10 / Q112);\r\n        uint112 _price1CumulativeLast = uint112(IArchiSwapPair(_pair).price1CumulativeLast() * e10 / Q112);\r\n        observations[length++] = Observation(timestamp, _price0CumulativeLast, _price1CumulativeLast);\r\n    }\r\n\r\n    struct Observation {\r\n        uint32 timestamp;\r\n        uint112 price0Cumulative;\r\n        uint112 price1Cumulative;\r\n    }\r\n\r\n    function cache(uint size) external {\r\n        uint _length = length+size;\r\n        for (uint i = length; i < _length; i++) observations[i].timestamp = 1;\r\n    }\r\n\r\n    function update() external onlyUpdater returns (bool) {\r\n        return _update();\r\n    }\r\n\r\n    function updateable() external view returns (bool) {\r\n        Observation memory _point = observations[length-1];\r\n        (,, uint timestamp) = IArchiSwapPair(pair).getReserves();\r\n        uint timeElapsed = timestamp - _point.timestamp;\r\n        return timeElapsed > periodSize;\r\n    }\r\n\r\n    function _update() internal returns (bool) {\r\n        Observation memory _point = observations[length-1];\r\n        (,, uint32 timestamp) = IArchiSwapPair(pair).getReserves();\r\n        uint32 timeElapsed = timestamp - _point.timestamp;\r\n        if (timeElapsed > periodSize) {\r\n            uint112 _price0CumulativeLast = uint112(IArchiSwapPair(pair).price0CumulativeLast() * e10 / Q112);\r\n            uint112 _price1CumulativeLast = uint112(IArchiSwapPair(pair).price1CumulativeLast() * e10 / Q112);\r\n            observations[length++] = Observation(timestamp, _price0CumulativeLast, _price1CumulativeLast);\r\n            return true;\r\n        }\r\n        return false;\r\n    }\r\n\r\n    function _computeAmountOut(uint start, uint end, uint elapsed, uint amountIn) internal view returns (uint amountOut) {\r\n        amountOut = amountIn * (end - start) / e10 / elapsed;\r\n    }\r\n\r\n    function current(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut, uint lastUpdatedAgo) {\r\n        (address token0,) = tokenIn < tokenOut ? (tokenIn, tokenOut) : (tokenOut, tokenIn);\r\n\r\n        Observation memory _observation = observations[length-1];\r\n        uint price0Cumulative = IArchiSwapPair(pair).price0CumulativeLast() * e10 / Q112;\r\n        uint price1Cumulative = IArchiSwapPair(pair).price1CumulativeLast() * e10 / Q112;\r\n        (,,uint timestamp) = IArchiSwapPair(pair).getReserves();\r\n\r\n        // Handle edge cases where we have no updates, will revert on first reading set\r\n        if (timestamp == _observation.timestamp) {\r\n            _observation = observations[length-2];\r\n        }\r\n\r\n        uint timeElapsed = timestamp - _observation.timestamp;\r\n        timeElapsed = timeElapsed == 0 ? 1 : timeElapsed;\r\n        if (token0 == tokenIn) {\r\n            amountOut = _computeAmountOut(_observation.price0Cumulative, price0Cumulative, timeElapsed, amountIn);\r\n        } else {\r\n            amountOut = _computeAmountOut(_observation.price1Cumulative, price1Cumulative, timeElapsed, amountIn);\r\n        }\r\n        lastUpdatedAgo = timeElapsed;\r\n    }\r\n\r\n    function setUpdater(address _newUpdater) external onlyUpdater {\r\n        updater = _newUpdater;\r\n    }\r\n\r\n    function setEveryoneUpdate(bool _newIsEveryoneUpdate) external onlyUpdater {\r\n        isEveryoneUpdate = _newIsEveryoneUpdate;\r\n    }\r\n\r\n    modifier onlyUpdater() {\r\n        if(!isEveryoneUpdate) {\r\n            require(msg.sender == updater, \"ONLY_UPDATER\");\r\n        }\r\n        _;\r\n    }\r\n}"
    }
  }
}}