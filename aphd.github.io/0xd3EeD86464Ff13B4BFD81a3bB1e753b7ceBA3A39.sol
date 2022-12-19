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
    "contracts/optimistic-ethereum/libraries/resolver/Lib_AddressManager.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.8.0;\n\n/* Contract Imports */\nimport { Ownable } from \"./Lib_Ownable.sol\";\n\n/**\n * @title Lib_AddressManager\n */\ncontract Lib_AddressManager is Ownable {\n\n    /**********\n     * Events *\n     **********/\n\n    event AddressSet(\n        string _name,\n        address _newAddress\n    );\n\n    /*******************************************\n     * Contract Variables: Internal Accounting *\n     *******************************************/\n\n    mapping (bytes32 => address) private addresses;\n\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    function setAddress(\n        string memory _name,\n        address _address\n    )\n        public\n        onlyOwner\n    {\n        emit AddressSet(_name, _address);\n        addresses[_getNameHash(_name)] = _address;\n    }\n\n    function getAddress(\n        string memory _name\n    )\n        public\n        view\n        returns (address)\n    {\n        return addresses[_getNameHash(_name)];\n    }\n\n\n    /**********************\n     * Internal Functions *\n     **********************/\n\n    function _getNameHash(\n        string memory _name\n    )\n        internal\n        pure\n        returns (\n            bytes32 _hash\n        )\n    {\n        return keccak256(abi.encodePacked(_name));\n    }\n}\n"
    },
    "contracts/optimistic-ethereum/libraries/resolver/Lib_Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >0.5.0 <0.8.0;\n\n/**\n * @title Ownable\n * @dev Adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol\n */\nabstract contract Ownable {\n\n    /*************\n     * Variables *\n     *************/\n\n    address public owner;\n\n\n    /**********\n     * Events *\n     **********/\n\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n\n\n    /***************\n     * Constructor *\n     ***************/\n\n    constructor() {\n        owner = msg.sender;\n        emit OwnershipTransferred(address(0), owner);\n    }\n\n\n    /**********************\n     * Function Modifiers *\n     **********************/\n\n    modifier onlyOwner() {\n        require(\n            owner == msg.sender,\n            \"Ownable: caller is not the owner\"\n        );\n        _;\n    }\n\n\n    /********************\n     * Public Functions *\n     ********************/\n\n    function renounceOwnership()\n        public\n        virtual\n        onlyOwner\n    {\n        emit OwnershipTransferred(owner, address(0));\n        owner = address(0);\n    }\n\n    function transferOwnership(address _newOwner)\n        public\n        virtual\n        onlyOwner\n    {\n        require(\n            _newOwner != address(0),\n            \"Ownable: new owner cannot be the zero address\"\n        );\n\n        emit OwnershipTransferred(owner, _newOwner);\n        owner = _newOwner;\n    }\n}\n"
    }
  }
}}