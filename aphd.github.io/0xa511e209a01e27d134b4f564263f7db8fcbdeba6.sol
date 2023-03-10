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
    "src/libs/Create2.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.0;\n\n/**\n * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.\n * `CREATE2` can be used to compute in advance the address where a smart\n * contract will be deployed, which allows for interesting new mechanisms known\n * as 'counterfactual interactions'.\n *\n * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more\n * information.\n */\nlibrary Create2 {\n    /**\n     * @dev Deploys a contract using `CREATE2`. The address where the contract\n     * will be deployed can be known in advance via {computeAddress}.\n     *\n     * The bytecode for a contract can be obtained from Solidity with\n     * `type(contractName).creationCode`.\n     *\n     * Requirements:\n     *\n     * - `bytecode` must not be empty.\n     * - `salt` must have not been used for `bytecode` already.\n     * - the factory must have a balance of at least `amount`.\n     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.\n     */\n    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {\n        address addr;\n        require(address(this).balance >= amount, \"Create2: insufficient balance\");\n        require(bytecode.length != 0, \"Create2: bytecode length is zero\");\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)\n        }\n        require(addr != address(0), \"Create2: Failed on deploy\");\n        return addr;\n    }\n\n    /**\n     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the\n     * `bytecodeHash` or `salt` will result in a new destination address.\n     */\n    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {\n        return computeAddress(salt, bytecodeHash, address(this));\n    }\n\n    /**\n     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at\n     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.\n     */\n    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {\n        bytes32 _data = keccak256(\n            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)\n        );\n        return address(uint160(uint256(_data)));\n    }\n}\n"
    }
  }
}}