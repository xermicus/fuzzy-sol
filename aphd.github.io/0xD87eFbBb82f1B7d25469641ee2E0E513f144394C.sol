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
    "contracts/optimistic-ethereum/OVM/execution/OVM_SafetyChecker.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.8.0;\n\n/* Interface Imports */\nimport { iOVM_SafetyChecker } from \"../../iOVM/execution/iOVM_SafetyChecker.sol\";\n\n/**\n * @title OVM_SafetyChecker\n * @dev  The Safety Checker verifies that contracts deployed on L2 do not contain any\n * \"unsafe\" operations. An operation is considered unsafe if it would access state variables which\n * are specific to the environment (ie. L1 or L2) in which it is executed, as this could be used\n * to \"escape the sandbox\" of the OVM, resulting in non-deterministic fraud proofs.\n * That is, an attacker would be able to \"prove fraud\" on an honestly applied transaction.\n * Note that a \"safe\" contract requires opcodes to appear in a particular pattern;\n * omission of \"unsafe\" opcodes is necessary, but not sufficient.\n *\n * Compiler used: solc\n * Runtime target: EVM\n */\ncontract OVM_SafetyChecker is iOVM_SafetyChecker {\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    /**\n     * Returns whether or not all of the provided bytecode is safe.\n     * @param _bytecode The bytecode to safety check.\n     * @return `true` if the bytecode is safe, `false` otherwise.\n     */\n    function isBytecodeSafe(\n        bytes memory _bytecode\n    )\n        override\n        external\n        pure\n        returns (\n            bool\n        )\n    {\n        // autogenerated by gen_safety_checker_constants.py\n        // number of bytes to skip for each opcode\n        uint256[8] memory opcodeSkippableBytes = [\n            uint256(0x0001010101010101010101010000000001010101010101010101010101010000),\n            uint256(0x0100000000000000000000000000000000000000010101010101000000010100),\n            uint256(0x0000000000000000000000000000000001010101000000010101010100000000),\n            uint256(0x0203040500000000000000000000000000000000000000000000000000000000),\n            uint256(0x0101010101010101010101010101010101010101010101010101010101010101),\n            uint256(0x0101010101000000000000000000000000000000000000000000000000000000),\n            uint256(0x0000000000000000000000000000000000000000000000000000000000000000),\n            uint256(0x0000000000000000000000000000000000000000000000000000000000000000)\n        ];\n        // Mask to gate opcode specific cases\n        uint256 opcodeGateMask = ~uint256(0xffffffffffffffffffffffe000000000fffffffff070ffff9c0ffffec000f001);\n        // Halting opcodes\n        uint256 opcodeHaltingMask = ~uint256(0x4008000000000000000000000000000000000000004000000000000000000001);\n        // PUSH opcodes\n        uint256 opcodePushMask = ~uint256(0xffffffff000000000000000000000000);\n\n        uint256 codeLength;\n        uint256 _pc;\n        assembly {\n            _pc := add(_bytecode, 0x20)\n        }\n        codeLength = _pc + _bytecode.length;\n        do {\n            // current opcode: 0x00...0xff\n            uint256 opNum;\n\n            // inline assembly removes the extra add + bounds check\n            assembly {\n                let word := mload(_pc) //load the next 32 bytes at pc into word\n\n                // Look up number of bytes to skip from opcodeSkippableBytes and then update indexInWord\n                // E.g. the 02030405 in opcodeSkippableBytes is the number of bytes to skip for PUSH1->4\n                // We repeat this 6 times, thus we can only skip bytes for up to PUSH4 ((1+4) * 6 = 30 < 32).\n                // If we see an opcode that is listed as 0 skippable bytes e.g. PUSH5,\n                // then we will get stuck on that indexInWord and then opNum will be set to the PUSH5 opcode.\n                let indexInWord := byte(0, mload(add(opcodeSkippableBytes, byte(0, word))))\n                indexInWord := add(indexInWord, byte(0, mload(add(opcodeSkippableBytes, byte(indexInWord, word)))))\n                indexInWord := add(indexInWord, byte(0, mload(add(opcodeSkippableBytes, byte(indexInWord, word)))))\n                indexInWord := add(indexInWord, byte(0, mload(add(opcodeSkippableBytes, byte(indexInWord, word)))))\n                indexInWord := add(indexInWord, byte(0, mload(add(opcodeSkippableBytes, byte(indexInWord, word)))))\n                indexInWord := add(indexInWord, byte(0, mload(add(opcodeSkippableBytes, byte(indexInWord, word)))))\n                _pc := add(_pc, indexInWord)\n\n                opNum := byte(indexInWord, word)\n            }\n\n            // + push opcodes\n            // + stop opcodes [STOP(0x00),JUMP(0x56),RETURN(0xf3),INVALID(0xfe)]\n            // + caller opcode CALLER(0x33)\n            // + blacklisted opcodes\n            uint256 opBit = 1 << opNum;\n            if (opBit & opcodeGateMask == 0) {\n                if (opBit & opcodePushMask == 0) {\n                    // all pushes are valid opcodes\n                    // subsequent bytes are not opcodes. Skip them.\n                    _pc += (opNum - 0x5e); // PUSH1 is 0x60, so opNum-0x5f = PUSHed bytes and we +1 to\n                    // skip the _pc++; line below in order to save gas ((-0x5f + 1) = -0x5e)\n                    continue;\n                } else if (opBit & opcodeHaltingMask == 0) {\n                    // STOP or JUMP or RETURN or INVALID (Note: REVERT is blacklisted, so not included here)\n                    // We are now inside unreachable code until we hit a JUMPDEST!\n                    do {\n                        _pc++;\n                        assembly {\n                            opNum := byte(0, mload(_pc))\n                        }\n                        // encountered a JUMPDEST\n                        if (opNum == 0x5b) break;\n                        // skip PUSHed bytes\n                        if ((1 << opNum) & opcodePushMask == 0) _pc += (opNum - 0x5f); // opNum-0x5f = PUSHed bytes (PUSH1 is 0x60)\n                    } while (_pc < codeLength);\n                    // opNum is 0x5b, so we don't continue here since the pc++ is fine\n                } else if (opNum == 0x33) { // Caller opcode\n                    uint256 firstOps; // next 32 bytes of bytecode\n                    uint256 secondOps; // following 32 bytes of bytecode\n\n                    assembly {\n                        firstOps := mload(_pc)\n                        // 37 bytes total, 5 left over --> 32 - 5 bytes = 27 bytes = 216 bits\n                        secondOps := shr(216, mload(add(_pc, 0x20)))\n                    }\n\n                    // Call identity precompile\n                    // CALLER POP PUSH1 0x00 PUSH1 0x04 GAS CALL\n                    // 32 - 8 bytes = 24 bytes = 192\n                    if ((firstOps >> 192) == 0x3350600060045af1) {\n                        _pc += 8;\n                    // Call EM and abort execution if instructed\n                    // CALLER PUSH1 0x00 SWAP1 GAS CALL PC PUSH1 0x0E ADD JUMPI RETURNDATASIZE PUSH1 0x00 DUP1 RETURNDATACOPY RETURNDATASIZE PUSH1 0x00 REVERT JUMPDEST RETURNDATASIZE PUSH1 0x01 EQ ISZERO PC PUSH1 0x0a ADD JUMPI PUSH1 0x01 PUSH1 0x00 RETURN JUMPDEST\n                    } else if (firstOps == 0x336000905af158600e01573d6000803e3d6000fd5b3d6001141558600a015760 && secondOps == 0x016000f35b) {\n                        _pc += 37;\n                    } else {\n                        return false;\n                    }\n                    continue;\n                } else {\n                    // encountered a non-whitelisted opcode!\n                    return false;\n                }\n            }\n            _pc++;\n        } while (_pc < codeLength);\n        return true;\n    }\n}\n"
    },
    "contracts/optimistic-ethereum/iOVM/execution/iOVM_SafetyChecker.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.8.0;\n\n/**\n * @title iOVM_SafetyChecker\n */\ninterface iOVM_SafetyChecker {\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    function isBytecodeSafe(bytes calldata _bytecode) external pure returns (bool);\n}\n"
    }
  }
}}