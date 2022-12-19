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
      "enabled": false,
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
    "contracts/dnssec-oracle/BytesUtils.sol": {
      "content": "pragma solidity ^0.8.4;\n\nlibrary BytesUtils {\n    /*\n    * @dev Returns the keccak-256 hash of a byte range.\n    * @param self The byte string to hash.\n    * @param offset The position to start hashing at.\n    * @param len The number of bytes to hash.\n    * @return The hash of the byte range.\n    */\n    function keccak(bytes memory self, uint offset, uint len) internal pure returns (bytes32 ret) {\n        require(offset + len <= self.length);\n        assembly {\n            ret := keccak256(add(add(self, 32), offset), len)\n        }\n    }\n\n\n    /*\n    * @dev Returns a positive number if `other` comes lexicographically after\n    *      `self`, a negative number if it comes before, or zero if the\n    *      contents of the two bytes are equal.\n    * @param self The first bytes to compare.\n    * @param other The second bytes to compare.\n    * @return The result of the comparison.\n    */\n    function compare(bytes memory self, bytes memory other) internal pure returns (int) {\n        return compare(self, 0, self.length, other, 0, other.length);\n    }\n\n    /*\n    * @dev Returns a positive number if `other` comes lexicographically after\n    *      `self`, a negative number if it comes before, or zero if the\n    *      contents of the two bytes are equal. Comparison is done per-rune,\n    *      on unicode codepoints.\n    * @param self The first bytes to compare.\n    * @param offset The offset of self.\n    * @param len    The length of self.\n    * @param other The second bytes to compare.\n    * @param otheroffset The offset of the other string.\n    * @param otherlen    The length of the other string.\n    * @return The result of the comparison.\n    */\n    function compare(bytes memory self, uint offset, uint len, bytes memory other, uint otheroffset, uint otherlen) internal pure returns (int) {\n        uint shortest = len;\n        if (otherlen < len)\n        shortest = otherlen;\n\n        uint selfptr;\n        uint otherptr;\n\n        assembly {\n            selfptr := add(self, add(offset, 32))\n            otherptr := add(other, add(otheroffset, 32))\n        }\n        for (uint idx = 0; idx < shortest; idx += 32) {\n            uint a;\n            uint b;\n            assembly {\n                a := mload(selfptr)\n                b := mload(otherptr)\n            }\n            if (a != b) {\n                // Mask out irrelevant bytes and check again\n                uint mask;\n                if (shortest > 32) {\n                    mask = type(uint256).max;\n                } else {\n                    mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);\n                }\n                int diff = int(a & mask) - int(b & mask);\n                if (diff != 0)\n                return diff;\n            }\n            selfptr += 32;\n            otherptr += 32;\n        }\n\n        return int(len) - int(otherlen);\n    }\n\n    /*\n    * @dev Returns true if the two byte ranges are equal.\n    * @param self The first byte range to compare.\n    * @param offset The offset into the first byte range.\n    * @param other The second byte range to compare.\n    * @param otherOffset The offset into the second byte range.\n    * @param len The number of bytes to compare\n    * @return True if the byte ranges are equal, false otherwise.\n    */\n    function equals(bytes memory self, uint offset, bytes memory other, uint otherOffset, uint len) internal pure returns (bool) {\n        return keccak(self, offset, len) == keccak(other, otherOffset, len);\n    }\n\n    /*\n    * @dev Returns true if the two byte ranges are equal with offsets.\n    * @param self The first byte range to compare.\n    * @param offset The offset into the first byte range.\n    * @param other The second byte range to compare.\n    * @param otherOffset The offset into the second byte range.\n    * @return True if the byte ranges are equal, false otherwise.\n    */\n    function equals(bytes memory self, uint offset, bytes memory other, uint otherOffset) internal pure returns (bool) {\n        return keccak(self, offset, self.length - offset) == keccak(other, otherOffset, other.length - otherOffset);\n    }\n\n    /*\n    * @dev Compares a range of 'self' to all of 'other' and returns True iff\n    *      they are equal.\n    * @param self The first byte range to compare.\n    * @param offset The offset into the first byte range.\n    * @param other The second byte range to compare.\n    * @return True if the byte ranges are equal, false otherwise.\n    */\n    function equals(bytes memory self, uint offset, bytes memory other) internal pure returns (bool) {\n        return self.length >= offset + other.length && equals(self, offset, other, 0, other.length);\n    }\n\n    /*\n    * @dev Returns true if the two byte ranges are equal.\n    * @param self The first byte range to compare.\n    * @param other The second byte range to compare.\n    * @return True if the byte ranges are equal, false otherwise.\n    */\n    function equals(bytes memory self, bytes memory other) internal pure returns(bool) {\n        return self.length == other.length && equals(self, 0, other, 0, self.length);\n    }\n\n    /*\n    * @dev Returns the 8-bit number at the specified index of self.\n    * @param self The byte string.\n    * @param idx The index into the bytes\n    * @return The specified 8 bits of the string, interpreted as an integer.\n    */\n    function readUint8(bytes memory self, uint idx) internal pure returns (uint8 ret) {\n        return uint8(self[idx]);\n    }\n\n    /*\n    * @dev Returns the 16-bit number at the specified index of self.\n    * @param self The byte string.\n    * @param idx The index into the bytes\n    * @return The specified 16 bits of the string, interpreted as an integer.\n    */\n    function readUint16(bytes memory self, uint idx) internal pure returns (uint16 ret) {\n        require(idx + 2 <= self.length);\n        assembly {\n            ret := and(mload(add(add(self, 2), idx)), 0xFFFF)\n        }\n    }\n\n    /*\n    * @dev Returns the 32-bit number at the specified index of self.\n    * @param self The byte string.\n    * @param idx The index into the bytes\n    * @return The specified 32 bits of the string, interpreted as an integer.\n    */\n    function readUint32(bytes memory self, uint idx) internal pure returns (uint32 ret) {\n        require(idx + 4 <= self.length);\n        assembly {\n            ret := and(mload(add(add(self, 4), idx)), 0xFFFFFFFF)\n        }\n    }\n\n    /*\n    * @dev Returns the 32 byte value at the specified index of self.\n    * @param self The byte string.\n    * @param idx The index into the bytes\n    * @return The specified 32 bytes of the string.\n    */\n    function readBytes32(bytes memory self, uint idx) internal pure returns (bytes32 ret) {\n        require(idx + 32 <= self.length);\n        assembly {\n            ret := mload(add(add(self, 32), idx))\n        }\n    }\n\n    /*\n    * @dev Returns the 32 byte value at the specified index of self.\n    * @param self The byte string.\n    * @param idx The index into the bytes\n    * @return The specified 32 bytes of the string.\n    */\n    function readBytes20(bytes memory self, uint idx) internal pure returns (bytes20 ret) {\n        require(idx + 20 <= self.length);\n        assembly {\n            ret := and(mload(add(add(self, 32), idx)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000)\n        }\n    }\n\n    /*\n    * @dev Returns the n byte value at the specified index of self.\n    * @param self The byte string.\n    * @param idx The index into the bytes.\n    * @param len The number of bytes.\n    * @return The specified 32 bytes of the string.\n    */\n    function readBytesN(bytes memory self, uint idx, uint len) internal pure returns (bytes32 ret) {\n        require(len <= 32);\n        require(idx + len <= self.length);\n        assembly {\n            let mask := not(sub(exp(256, sub(32, len)), 1))\n            ret := and(mload(add(add(self, 32), idx)),  mask)\n        }\n    }\n\n    function memcpy(uint dest, uint src, uint len) private pure {\n        // Copy word-length chunks while possible\n        for (; len >= 32; len -= 32) {\n            assembly {\n                mstore(dest, mload(src))\n            }\n            dest += 32;\n            src += 32;\n        }\n\n        // Copy remaining bytes\n        unchecked {\n            uint mask = (256 ** (32 - len)) - 1;\n            assembly {\n                let srcpart := and(mload(src), not(mask))\n                let destpart := and(mload(dest), mask)\n                mstore(dest, or(destpart, srcpart))\n            }\n        }\n    }\n\n    /*\n    * @dev Copies a substring into a new byte string.\n    * @param self The byte string to copy from.\n    * @param offset The offset to start copying at.\n    * @param len The number of bytes to copy.\n    */\n    function substring(bytes memory self, uint offset, uint len) internal pure returns(bytes memory) {\n        require(offset + len <= self.length);\n\n        bytes memory ret = new bytes(len);\n        uint dest;\n        uint src;\n\n        assembly {\n            dest := add(ret, 32)\n            src := add(add(self, 32), offset)\n        }\n        memcpy(dest, src, len);\n\n        return ret;\n    }\n\n    // Maps characters from 0x30 to 0x7A to their base32 values.\n    // 0xFF represents invalid characters in that range.\n    bytes constant base32HexTable = hex'00010203040506070809FFFFFFFFFFFFFF0A0B0C0D0E0F101112131415161718191A1B1C1D1E1FFFFFFFFFFFFFFFFFFFFF0A0B0C0D0E0F101112131415161718191A1B1C1D1E1F';\n\n    /**\n     * @dev Decodes unpadded base32 data of up to one word in length.\n     * @param self The data to decode.\n     * @param off Offset into the string to start at.\n     * @param len Number of characters to decode.\n     * @return The decoded data, left aligned.\n     */\n    function base32HexDecodeWord(bytes memory self, uint off, uint len) internal pure returns(bytes32) {\n        require(len <= 52);\n\n        uint ret = 0;\n        uint8 decoded;\n        for(uint i = 0; i < len; i++) {\n            bytes1 char = self[off + i];\n            require(char >= 0x30 && char <= 0x7A);\n            decoded = uint8(base32HexTable[uint(uint8(char)) - 0x30]);\n            require(decoded <= 0x20);\n            if(i == len - 1) {\n                break;\n            }\n            ret = (ret << 5) | decoded;\n        }\n\n        uint bitlen = len * 5;\n        if(len % 8 == 0) {\n            // Multiple of 8 characters, no padding\n            ret = (ret << 5) | decoded;\n        } else if(len % 8 == 2) {\n            // Two extra characters - 1 byte\n            ret = (ret << 3) | (decoded >> 2);\n            bitlen -= 2;\n        } else if(len % 8 == 4) {\n            // Four extra characters - 2 bytes\n            ret = (ret << 1) | (decoded >> 4);\n            bitlen -= 4;\n        } else if(len % 8 == 5) {\n            // Five extra characters - 3 bytes\n            ret = (ret << 4) | (decoded >> 1);\n            bitlen -= 1;\n        } else if(len % 8 == 7) {\n            // Seven extra characters - 4 bytes\n            ret = (ret << 2) | (decoded >> 3);\n            bitlen -= 3;\n        } else {\n            revert();\n        }\n\n        return bytes32(ret << (256 - bitlen));\n    }\n}"
    },
    "contracts/dnssec-oracle/algorithms/Algorithm.sol": {
      "content": "pragma solidity ^0.8.4;\n\n/**\n* @dev An interface for contracts implementing a DNSSEC (signing) algorithm.\n*/\ninterface Algorithm {\n    /**\n    * @dev Verifies a signature.\n    * @param key The public key to verify with.\n    * @param data The signed data to verify.\n    * @param signature The signature to verify.\n    * @return True iff the signature is valid.\n    */\n    function verify(bytes calldata key, bytes calldata data, bytes calldata signature) external virtual view returns (bool);\n}\n"
    },
    "contracts/dnssec-oracle/algorithms/ModexpPrecompile.sol": {
      "content": "pragma solidity ^0.8.4;\n\nlibrary ModexpPrecompile {\n    /**\n    * @dev Computes (base ^ exponent) % modulus over big numbers.\n    */\n    function modexp(bytes memory base, bytes memory exponent, bytes memory modulus) internal view returns (bool success, bytes memory output) {\n        bytes memory input = abi.encodePacked(\n            uint256(base.length),\n            uint256(exponent.length),\n            uint256(modulus.length),\n            base,\n            exponent,\n            modulus\n        );\n\n        output = new bytes(modulus.length);\n\n        assembly {\n            success := staticcall(gas(), 5, add(input, 32), mload(input), add(output, 32), mload(modulus))\n        }\n    }\n}\n"
    },
    "contracts/dnssec-oracle/algorithms/RSASHA256Algorithm.sol": {
      "content": "pragma solidity ^0.8.4;\n\nimport \"./Algorithm.sol\";\nimport \"../BytesUtils.sol\";\nimport \"./RSAVerify.sol\";\n\n/**\n* @dev Implements the DNSSEC RSASHA256 algorithm.\n*/\ncontract RSASHA256Algorithm is Algorithm {\n    using BytesUtils for *;\n\n    function verify(bytes calldata key, bytes calldata data, bytes calldata sig) external override view returns (bool) {\n        bytes memory exponent;\n        bytes memory modulus;\n\n        uint16 exponentLen = uint16(key.readUint8(4));\n        if (exponentLen != 0) {\n            exponent = key.substring(5, exponentLen);\n            modulus = key.substring(exponentLen + 5, key.length - exponentLen - 5);\n        } else {\n            exponentLen = key.readUint16(5);\n            exponent = key.substring(7, exponentLen);\n            modulus = key.substring(exponentLen + 7, key.length - exponentLen - 7);\n        }\n\n        // Recover the message from the signature\n        bool ok;\n        bytes memory result;\n        (ok, result) = RSAVerify.rsarecover(modulus, exponent, sig);\n\n        // Verify it ends with the hash of our data\n        return ok && sha256(data) == result.readBytes32(result.length - 32);\n    }\n}\n"
    },
    "contracts/dnssec-oracle/algorithms/RSAVerify.sol": {
      "content": "pragma solidity ^0.8.4;\n\nimport \"../BytesUtils.sol\";\nimport \"./ModexpPrecompile.sol\";\n\nlibrary RSAVerify {\n    /**\n    * @dev Recovers the input data from an RSA signature, returning the result in S.\n    * @param N The RSA public modulus.\n    * @param E The RSA public exponent.\n    * @param S The signature to recover.\n    * @return True if the recovery succeeded.\n    */\n    function rsarecover(bytes memory N, bytes memory E, bytes memory S) internal view returns (bool, bytes memory) {\n        return ModexpPrecompile.modexp(S, E, N);\n    }\n}\n"
    }
  }
}}