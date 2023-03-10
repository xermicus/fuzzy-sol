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
      "runs": 9999
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
    "src/libs/Strings.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.7.0;\n\nlibrary Strings {\n    function strConcat(\n        string memory _a,\n        string memory _b,\n        string memory _c,\n        string memory _d,\n        string memory _e\n    ) internal pure returns (string memory) {\n        bytes memory _ba = bytes(_a);\n        bytes memory _bb = bytes(_b);\n        bytes memory _bc = bytes(_c);\n        bytes memory _bd = bytes(_d);\n        bytes memory _be = bytes(_e);\n        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);\n        bytes memory babcde = bytes(abcde);\n        uint256 k = 0;\n        for (uint256 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];\n        for (uint256 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];\n        for (uint256 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];\n        for (uint256 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];\n        for (uint256 i = 0; i < _be.length; i++) babcde[k++] = _be[i];\n        return string(babcde);\n    }\n\n    function strConcat(\n        string memory _a,\n        string memory _b,\n        string memory _c,\n        string memory _d\n    ) internal pure returns (string memory) {\n        return strConcat(_a, _b, _c, _d, \"\");\n    }\n\n    function strConcat(\n        string memory _a,\n        string memory _b,\n        string memory _c\n    ) internal pure returns (string memory) {\n        return strConcat(_a, _b, _c, \"\", \"\");\n    }\n\n    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {\n        return strConcat(_a, _b, \"\", \"\", \"\");\n    }\n\n    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {\n        if (_i == 0) {\n            return \"0\";\n        }\n        uint256 j = _i;\n        uint256 len;\n        while (j != 0) {\n            len++;\n            j /= 10;\n        }\n        bytes memory bstr = new bytes(len);\n        uint256 k = len - 1;\n        while (_i != 0) {\n            bstr[k--] = bytes1(uint8(48 + (_i % 10)));\n            _i /= 10;\n        }\n        return string(bstr);\n    }\n}\n"
    }
  }
}}