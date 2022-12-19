{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
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
    "contracts/Batcher.sol": {
      "content": "pragma solidity ^0.7.0;\npragma abicoder v2;\n\ncontract Batcher {\n  function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {\n    // If the _res length is less than 68, then the transaction failed silently (without a revert message)\n    if (_returnData.length < 68) return \"Transaction reverted silently\";\n\n    assembly {\n      // Slice the sighash.\n      _returnData := add(_returnData, 0x04)\n    }\n    return abi.decode(_returnData, (string)); // All that remains is the revert string\n  }\n\n  function batch(\n    bytes[] memory calls\n  ) public payable returns (bytes[] memory results) {\n    // Interactions\n    results = new bytes[](calls.length);\n    for (uint256 i = 0; i < calls.length; i++) {\n      bytes memory data = calls[i];\n      address target;\n      bool doDelegate;\n      uint88 value;\n      assembly {\n\n        let opts := mload(add(data, mload(data)))\n        target := shr(96, opts)\n        doDelegate := byte(20, opts)\n        value := and(opts, 0xffffffffffffffffffffff)\n        mstore(data, sub(mload(data), 32))\n      }\n      (bool success, bytes memory result) = doDelegate ? target.delegatecall(data) : target.call{value: value}(data);\n      if (!success) {\n        revert(_getRevertMsg(result));\n      }\n      results[i] = result;\n    }\n  }\n}"
    }
  }
}}