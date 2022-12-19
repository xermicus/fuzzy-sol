{"OracleWrapperInverse.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.6.0 \u003c0.8.0;\npragma abicoder v2;\n\nimport \"./Ownable.sol\";\nimport \"./SafeMath.sol\";\n\n\ninterface OracleInterface{\n    function latestAnswer() external view returns (int256);\n}\n\ninterface tellorInterface{\n     function getLastNewValueById(uint _requestId) external view returns(uint,bool);\n}\n\ninterface uniswapInterface{\n     function getAmountsOut(uint amountIn, address[] memory path)\n        external view returns (uint[] memory amounts);\n}\ninterface Token{\n    function decimals() external view returns(uint256);\n}\ncontract OracleWrapperInverse is Ownable{\n    \n    using SafeMath for uint256;\n    \n    //Mainnet\n    address public tellerContractAddress=0x0Ba45A8b5d5575935B8158a88C631E9F9C95a2e5;\n    address public UniswapV2Router02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;\n    address public usdtContractAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;\n    \n    struct TellorInfo{\n        uint256 id;\n        uint256 tellorPSR;\n    }\n    uint256 tellorId=1;\n    mapping(string=\u003eaddress) public typeOneMapping;  // chainlink\n    string[] typeOneArray;\n    mapping(string=\u003e TellorInfo) public typeTwomapping; // tellor\n    string[] typeTwoArray;\n    mapping(string=\u003e address) public typeThreemapping; // uniswap\n    string[] typeThreeArray;\n\n    function updateTellerContractAddress(address newAddress) public onlyOwner{\n        tellerContractAddress = newAddress;\n    }\n    \n    function addTypeOneMapping(string memory currencySymbol, address chainlinkAddress) external onlyOwner{\n        typeOneMapping[currencySymbol]=chainlinkAddress;\n        if(!checkAddressIfExists(typeOneArray,currencySymbol)){\n            typeOneArray.push(currencySymbol);\n        }\n    }\n    \n    function addTypeTwoMapping(string memory currencySymbol, uint256 tellorPSR) external onlyOwner{\n        TellorInfo memory tInfo= TellorInfo({\n            id:tellorId,\n            tellorPSR:tellorPSR\n        });\n        typeTwomapping[currencySymbol]=tInfo;\n        tellorId++;\n        if(!checkAddressIfExists(typeTwoArray,currencySymbol)){\n            typeTwoArray.push(currencySymbol);\n        }\n    }\n    \n    function addTypeThreeMapping(string memory currencySymbol, address tokenContractAddress) external onlyOwner{\n        typeThreemapping[currencySymbol]=tokenContractAddress;\n        if(!checkAddressIfExists(typeThreeArray,currencySymbol)){\n            typeThreeArray.push(currencySymbol);\n        }\n    }\n    function checkAddressIfExists(string[] memory arr, string memory currencySymbol) internal pure returns(bool){\n        for(uint256 i=0;i\u003carr.length;i++){\n            if((keccak256(abi.encodePacked(arr[i]))) == (keccak256(abi.encodePacked(currencySymbol)))){\n                return true;\n            }\n        }\n        return false;\n    }\n    function getPrice(string memory currencySymbol,\n        uint256 oracleType) external view returns (uint256){\n        //oracletype 1 - chainlink and  for teller --2, uniswap---3\n        if(oracleType == 1){\n            require(typeOneMapping[currencySymbol]!=address(0), \"please enter valid currency\");\n            OracleInterface oObj = OracleInterface(typeOneMapping[currencySymbol]);\n            return uint256(oObj.latestAnswer());\n        }\n        else if(oracleType ==2){\n            require(typeTwomapping[currencySymbol].id!=0, \"please enter valid currency\");\n            tellorInterface tObj = tellorInterface(tellerContractAddress);\n            uint256 actualFiatPrice;\n            bool statusTellor;\n            (actualFiatPrice,statusTellor) = tObj.getLastNewValueById(typeTwomapping[currencySymbol].tellorPSR);\n            return uint256(actualFiatPrice);\n        }else{\n            require(typeThreemapping[currencySymbol]!=address(0), \"please enter valid currency\");\n            uniswapInterface uObj = uniswapInterface(UniswapV2Router02);\n            address[] memory path = new address[](2);\n            path[0] = typeThreemapping[currencySymbol];\n            path[1] = usdtContractAddress;\n            uint[] memory values=uObj.getAmountsOut(10**(Token(typeThreemapping[currencySymbol]).decimals()),path);\n            uint256 usdtDecimals=Token(usdtContractAddress).decimals();\n            if(usdtDecimals==8){\n                return uint256(values[1]);\n            }else{\n                return uint256(values[1].mul(10**(8-usdtDecimals)));\n            }\n        }\n    }\n    \n    function getTypeOneArray() external view returns(string[] memory){\n        return typeOneArray;\n    }\n    \n    function getTypeTwoArray() external view returns(string[] memory){\n        return typeTwoArray;\n    }\n    function getTypeThreeArray() external view returns(string[] memory){\n        return typeThreeArray;\n    }\n    function updateUniswapV2Router02(address _UniswapV2Router02) external onlyOwner{\n        UniswapV2Router02=_UniswapV2Router02;\n    }\n    function updateUSDTContractAddress(address _usdtContractAddress) external onlyOwner{\n        usdtContractAddress=_usdtContractAddress;\n    }\n}\n\n\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\ncontract Ownable {\n\n    address public owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n     * account.\n     */\n    constructor(){\n        _setOwner(msg.sender);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(msg.sender == owner);\n        _;\n    }\n\n    /**\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\n     * @param newOwner The address to transfer ownership to.\n     */\n    function transferOwnership(address newOwner) public onlyOwner {\n        require(newOwner != address(0));\n        emit OwnershipTransferred(owner, newOwner);\n        owner = newOwner;\n    }\n    \n    function _setOwner(address newOwner) internal {\n        owner = newOwner;\n    }\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\n * checks.\n *\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\n * in bugs, because programmers usually assume that an overflow raises an\n * error, which is the standard behavior in high level programming languages.\n * `SafeMath` restores this intuition by reverting the transaction when an\n * operation overflows.\n *\n * Using this library instead of the unchecked operations eliminates an entire\n * class of bugs, so it\u0027s recommended to use it always.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n        // benefit is lost if \u0027b\u0027 is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003e 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n\n        return c;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * Reverts with custom message when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n\n\n"}}