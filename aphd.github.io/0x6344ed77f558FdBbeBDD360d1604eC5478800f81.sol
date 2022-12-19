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
    "contracts/Proxy/Auth.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\nimport {IAuthority} from './interfaces/IAuthority.sol';\n\ncontract Auth {\n    IAuthority public authority;\n    address public owner;\n\n    error Unauthorized();\n\n    event LogSetAuthority(address indexed authority);\n    event LogSetOwner(address indexed owner);\n\n    constructor() {\n        owner = msg.sender;\n        emit LogSetOwner(msg.sender);\n    }\n\n    function setOwner(address owner_) public auth {\n        owner = owner_;\n        emit LogSetOwner(owner);\n    }\n\n    function setAuthority(address authority_) public auth {\n        authority = IAuthority(authority_);\n        emit LogSetAuthority(authority_);\n    }\n\n    modifier auth() {\n        if (!isAuthorized(msg.sender, msg.sig)) {\n            revert Unauthorized();\n        }\n        _;\n    }\n\n    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {\n        if (src == address(this)) {\n            return true;\n        } else if (src == owner) {\n            return true;\n        } else if (address(authority) == address(0)) {\n            return false;\n        } else {\n            return authority.canCall(src, address(this), sig);\n        }\n    }\n}\n"
    },
    "contracts/Proxy/Proxy.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\nimport {IProxyCache} from './interfaces/IProxyCache.sol';\nimport {Auth} from './Auth.sol';\n\ncontract Proxy is Auth {\n    IProxyCache public cache;\n\n    event WriteToCache(address target);\n\n    error ZeroTarget();\n    error SetCacheError();\n    error Unsuccessful();\n\n    constructor(address _cache) Auth() {\n        setCache(_cache);\n    }\n\n    function setCache(address _cache) public auth {\n        if (_cache == address(0)) {\n            revert ZeroTarget();\n        }\n        cache = IProxyCache(_cache);\n    }\n\n    function execute(bytes calldata _code, bytes calldata _data) public payable {\n        address target = cache.read(_code);\n        if (target == address(0)) {\n            target = cache.write(_code);\n            emit WriteToCache(target);\n        }\n        execute(target, _data);\n    }\n\n    function execute(address _target, bytes memory _data) public payable auth {\n        if (_target == address(0)) {\n            revert ZeroTarget();\n        }\n        (bool success, ) = _target.delegatecall(_data);\n        if (!success) {\n            revert Unsuccessful();\n        }\n    }\n\n    function executeCall(\n        address _target,\n        uint256 _amount,\n        bytes memory _data\n    ) public payable auth {\n        (bool success, ) = _target.call{value: _amount}(_data);\n        if (!success) {\n            revert Unsuccessful();\n        }\n    }\n\n    fallback() external payable {}\n\n    receive() external payable {}\n}\n"
    },
    "contracts/Proxy/interfaces/IAuthority.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\ninterface IAuthority {\n    function canCall(\n        address src,\n        address dst,\n        bytes4 sig\n    ) external view returns (bool);\n}\n"
    },
    "contracts/Proxy/interfaces/IProxyCache.sol": {
      "content": "//SPDX-License-Identifier: Unlicense\npragma solidity ^0.8.6;\n\ninterface IProxyCache {\n    function read(bytes memory _code) external view returns (address);\n\n    function write(bytes memory _code) external returns (address target);\n}\n"
    }
  }
}}